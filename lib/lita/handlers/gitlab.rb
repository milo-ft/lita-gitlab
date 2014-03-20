module Lita
  module Handlers
    class Gitlab < Handler

      def self.default_config(config)
        config.default_room = '#general'
      end

      http.post '/lita/gitlab', :receive

      def receive(request, response)
        json_body = request.params['payload'] || extract_json_from_request(request)
        data = symbolize parse_payload(json_body)
        message = format_message(data)
        targets = request.params['targets'] || '#general'
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

      def extract_json_from_request(request)
        request.body.rewind
        request.body.read
      end

      def format_message(data)
        data.key?(:event_name) ? system_message(data) : web_message(data)
      end

      def system_message(data)
        build_message "system.#{data[:event_name]}", data
      rescue
        Lita.logger.warn "Error formatting message: #{data.inspect}"
      end

      def web_message(data)
        if data.key? :object_kind
          if data[:object_attributes].key? :target_branch
            # Merge request
            data[:object_attributes][:link] = "#{data[:object_attributes][:target_branch]}/#{data[:object_attributes][:iid]}"
            build_message "web.#{data[:object_kind]}.#{data[:object_attributes][:state]}", data[:object_attributes]
          else
            # Issue
            build_message "web.#{data[:object_kind]}.#{data[:object_attributes][:state]}", data[:object_attributes]
          end
        else
          # Push has no object kind
          branch = data[:ref].split('/').drop(2).join('/')
          data[:link] = data[:repository][:name]
          if data[:before] =~ /^0+$/
            build_message 'web.push.new_branch', data
          else
            build_message 'web.push.add_to_branch', data
          end
        end
      rescue
        Lita.logger.warn "Error formatting message: #{data.inspect}"
      end

      # General methods

      def build_message(key, data)
        t(key) % data
      end

      def parse_payload(payload)
        MultiJson.load(payload)
      rescue MultiJson::LoadError => e
        Lita.logger.error("Could not parse JSON payload from Github: #{e.message}")
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
