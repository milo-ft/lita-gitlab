require 'spec_helper'

describe Lita::Handlers::Gitlab, lita_handler: true do

  let(:request) do
    request = double('Rack::Request')
    allow(request).to receive(:params).and_return(params)
    request
  end
  let(:response) { Rack::Response.new }
  let(:params) { double('Hash') }

  # System Hooks
  describe '#receive_system' do

    it { routes_http(:post, '/gitlab/system').to(:receive_system) }

    context 'when new team member' do
      let(:new_team_member_payload) { fixture_file('system/new_team_member') }
      before do
        Lita.config.handlers.gitlab.repos['milo-ft/testing'] = '#baz'
        allow(params).to receive(:[]).with('payload').and_return(new_team_member_payload)
      end

      it 'notifies to the applicable rooms' do
        expect(robot).to receive(:send_message) do |target, message|
          expect(target.room).to eq('#baz')
          expect(message).to include 'new'
        end
        subject.receive(request, response)
      end
    end

    context 'when project created' do
      let(:project_created_payload) { fixture_file('system/project_created') }
      before do
        Lita.config.handlers.gitlab.repos['milo-ft/testing'] = '#baz'
        allow(params).to receive(:[]).with('payload').and_return(new_team_member_payload)
      end

      it 'notifies to the applicable rooms' do
        expect(robot).to receive(:send_message) do |target, message|
          expect(target.room).to eq('#baz')
          expect(message).to include 'created'
        end
        subject.receive(request, response)
      end
    end

    context 'when project destroyed' do
      let(:project_destroyed_payload) { fixture_file('system/project_destroyed') }
      before do
        Lita.config.handlers.gitlab.repos['milo-ft/testing'] = '#baz'
        allow(params).to receive(:[]).with('payload').and_return(new_team_member_payload)
      end

      it 'notifies to the applicable rooms' do
        expect(robot).to receive(:send_message) do |target, message|
          expect(target.room).to eq('#baz')
          expect(message).to include 'destroyed'
        end
        subject.receive(request, response)
      end
    end
  end

  # Project Web Hooks
  describe '#receive_web' do

    it { routes_http(:post, '/gitlab/web').to(:receive_web) }

    context 'when issue event' do
      let(:issue_payload) { fixture_file('web/issue') }
      before do
        Lita.config.handlers.gitlab.repos['milo-ft/testing'] = '#baz'
        allow(params).to receive(:[]).with('payload').and_return(issue_payload)
      end

      it 'notifies to the applicable rooms' do
        expect(robot).to receive(:send_message) do |target, message|
          expect(target.room).to eq('#baz')
          expect(message).to include 'new issue'
        end
        subject.receive(request, response)
      end
    end

    context 'when push event' do
      let(:push_payload) { fixture_file('web/push') }
      before do
        Lita.config.handlers.gitlab.repos['milo-ft/testing'] = '#baz'
        allow(params).to receive(:[]).with('payload').and_return(push_payload)
      end

      it 'notifies to the applicable rooms' do
        expect(robot).to receive(:send_message) do |target, message|
          expect(target.room).to eq('#baz')
          expect(message).to include 'new push'
        end
        subject.receive(request, response)
      end
    end

    context 'when merge request event' do
      let(:merge_request_payload) { fixture_file('web/merge_request') }
      before do
        Lita.config.handlers.gitlab.repos['milo-ft/testing'] = '#baz'
        allow(params).to receive(:[]).with('payload').and_return(merge_request_payload)
      end

      it 'notifies to the applicable rooms' do
        expect(robot).to receive(:send_message) do |target, message|
          expect(target.room).to eq('#baz')
          expect(message).to include 'new merge request'
        end
        subject.receive(request, response)
      end
    end
  end
end
