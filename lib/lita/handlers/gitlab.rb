module Lita
  module Handlers
    class Gitlab < Handler

      def self.default_config(config)
        config.default_room = '#general'
        config.url = 'http://example.gitlab/'
        config.group = 'group_name'
      end

      http.post '/lita/gitlab', :receive

      def receive(request, response)
        json_body = request.params['payload'] || extract_json_from_request(request)
        data = symbolize parse_payload(json_body)
        data[:project] = request.params['project']
        message = format_message(data)
        if message
          targets = request.params['targets'] || Lita.config.handlers.gitlab.default_room
          rooms = []
          targets.split(',').each do |param_target|
            rooms << param_target
          end
          rooms.each do |room|
            target = Source.new(room: room)
            robot.send_message(target, message)
          end
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
        interpolate_message "system.#{data[:event_name]}", data
      rescue
        Lita.logger.warn "Error formatting message: #{data.inspect}"
      end

      def web_message(data)
        if data.key? :object_kind
          # Merge has target branch
          if data[:object_kind] =~ /merge_request/
            build_merge_message(data)
          elsif data[:object_kind] =~ /issue/
            build_issue_message(data)
          elsif data[:object_kind] =~ /note/
            build_note_message(data)
          else # tag_push, wiki_page, pipeline
            Lita.logger.warn "Ignored event: #{data.inspect}"
          end
        else
          # Push has no object kind
          build_branch_message(data)
        end
      rescue
        Lita.logger.warn "Error formatting message: #{data.inspect}"
      end

      def build_issue_message(data)
        interpolate_message "web.#{data[:object_kind]}.#{data[:object_attributes][:state]}", data[:object_attributes]
      end

      def build_note_message(data)
        if data[:object_attributes][:noteable_type] =~ /MergeRequest/
          interpolate_message "web.note.merge_request", data[:merge_request]
        elsif data[:object_attributes][:noteable_type] =~ /Issue/
          interpolate_message "web.note.issue", data[:issue]
        elsif data[:object_attributes][:noteable_type] =~ /Snippet/
          interpolate_message "web.note.snippet", data[:snippet]
        elsif data[:object_attributes][:noteable_type] =~ /Commit/
          interpolate_message "web.note.commit", data[:commit]
        else # e.g. new type
          Lita.logger.warn "Ignored note message: #{data.inspect}"
        end
      end

      def build_branch_message(data)
        branch = data[:ref].split('/').drop(2).join('/')
        data[:link] = "<#{data[:repository][:homepage]}|#{data[:repository][:name]}>"
        if data[:before] =~ /^0+$/
          interpolate_message 'web.push.new_branch', data
        else
          interpolate_message 'web.push.add_to_branch', data
        end
      end

      def build_merge_message(data)
        url = "#{Lita.config.handlers.gitlab.url}"
        url += if data[:project] then
                 "#{Lita.config.handlers.gitlab.group}/#{data[:project]}/merge_requests/#{data[:object_attributes][:iid]}"
               else
                 "groups/#{Lita.config.handlers.gitlab.group}"
               end
        data[:object_attributes][:project] = data[:project]
        data[:object_attributes][:link] = "<#{url}|#{data[:object_attributes][:title]}>"
        interpolate_message "web.#{data[:object_kind]}.#{data[:object_attributes][:state]}", data[:object_attributes]
      end

      # General methods

      def interpolate_message(key, data)
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
