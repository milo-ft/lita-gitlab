module Lita
  module Handlers
    class Gitlab < Handler

      def self.default_config(config)
        config.repos = {}
      end

      http.post '/lita/gitlab', :receive

      def receive(request, response)
        json_data = parse_json(request.params['payload']) or return
        data = symbolize(json_data)
        message = format_message(data)
        rooms = []
        if params['targets']
          params['targets'].each do |param_target|
            rooms << param_target
          end
        else
          rooms = '#general'
          #Lita.config.handlers.gitlab.default_room
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
      def parse_json(payload)
        MultiJson.load(payload)
      rescue MultiJson::LoadError => e
        Lita.logger.error("Could not parse JSON payload from Gitlab: #{e.message}")
        return
      end

      def symbolize(obj)
        return obj.inject({}){|memo,(k,v)| memo[k.to_sym] =  symbolize(v); memo} if obj.is_a? Hash
        return obj.inject([]){|memo,v    | memo           << symbolize(v); memo} if obj.is_a? Array
        return obj
      end

    end

    Lita.register_handler(Gitlab)
  end
end
