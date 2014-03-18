module Lita
  module Handlers
    class Gitlab < Handler

      def self.default_config(config)
        config.repos = {}
      end

      http.post '/lita/gitlab', :receive

      def receive(request, response)
        request.body.rewind
        json_data = JSON.parse(request.body.read) or return
        data = symbolize(json_data)
        message = format_message(data)
        targets = request.params['targets'] || Lita.config.handlers.gitlab.default_room || '#general'
        rooms = []
        targets.split(',').each do |param_target|
          rooms << param_target
        end
        rooms.each do |room|
          target = Source.new(room: room)
          robot.send_message(target, message)
        end
      end

      private

      def format_message(data)
        (data.key? :event_name) ? system_message(data) : web_message(data)
      end

      def system_message(data)
        t("system.#{data[:event_name]}") % data
      rescue
        Lita.logger.warn "Error formatting message: #{data.inspect}"
      end

      def web_message(data)
        if data.key? :object_kind
            t("web.#{data[:object_kind]}.#{data[:object_attributes][:state]}") % data[:object_attributes]
        else
          # Push has no object kind
          branch = data[:ref].split('/').drop(2).join('/')
          if data[:before] =~ /^0+$/
            t('web.push.new_branch') % data
          else
            t('web.push.add_to_branch') % data
          end
        end
      rescue
        Lita.logger.warn "Error formatting message: #{data.inspect}"
      end

      # General methods
      def symbolize(obj)
        return obj.inject({}){|memo,(k,v)| memo[k.to_sym] =  symbolize(v); memo} if obj.is_a? Hash
        return obj.inject([]){|memo,v    | memo           << symbolize(v); memo} if obj.is_a? Array
        return obj
      end

    end

    Lita.register_handler(Gitlab)
  end
end
