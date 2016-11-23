require 'spec_helper'

describe Lita::Handlers::Gitlab, lita_handler: true do

  http_route_path = '/lita/gitlab'

  it 'registers with Lita' do
    expect(Lita.handlers).to include(described_class)
  end

  it "registers HTTP route POST #{http_route_path} to :receive" do
    routes_http(:post, http_route_path).to(:receive)
  end

  let(:request) do
    request = double('Rack::Request')
    allow(request).to receive(:params).and_return(params)
    request
  end
  let(:response) { Rack::Response.new }
  let(:params) { {} }
  let(:targets) { '#baz' }
  let(:project) { 'test_project' }
  let(:matchers) {
    {
      new_team_member: 'John Smith has joined to the StoreCloud project',
      project_created: 'John Smith has created the StoreCloud project!',
      project_destroyed: 'John Smith has destroyed the Underscore project!',
      issue_opened: 'New issue >> New API: create/update/delete file: Create new API for manipulations with repository',
      add_to_branch: "John Smith added 4 commits to branch '<http://example.com/mike/diaspora | Diaspora>' in project test_project",
      merge_request_opened: 'New merge-request #1 en test_project: <http://example.com/diaspora/merge_requests/1 | MS-Viewport>',
      note_on_commit: '',
      note_on_issue: '',
      note_on_merge_request: '',
      note_on_snippet: '',
    }
  }

  describe '#receive' do
    before :each do
      allow(params).to receive(:[]).with('targets').and_return(targets)
      allow(params).to receive(:[]).with('project').and_return(project)
    end

    context 'with system hook' do

      context 'when new team member' do
        let(:new_team_member_payload) { fixture_file('system/new_team_member') }
        before do
          allow(params).to receive(:[]).with('payload').and_return(new_team_member_payload)
        end

        it 'notifies to the applicable rooms' do
          expect(robot).to receive(:send_message) do |target, message|
            expect(target.room).to eq('#baz')
            expect(message).to eq matchers[:new_team_member]
          end
          subject.receive(request, response)
        end
      end

      context 'when project created' do
        let(:project_created_payload) { fixture_file('system/project_created') }
        before do
          allow(params).to receive(:[]).with('payload').and_return(project_created_payload)
        end

        it 'notifies to the applicable rooms' do
          expect(robot).to receive(:send_message) do |target, message|
            expect(target.room).to eq('#baz')
            expect(message).to eq matchers[:project_created]
          end
          subject.receive(request, response)
        end
      end

      context 'when project destroyed' do
        let(:project_destroyed_payload) { fixture_file('system/project_destroyed') }
        before do
          allow(params).to receive(:[]).with('payload').and_return(project_destroyed_payload)
        end

        it 'notifies to the applicable rooms' do
          expect(robot).to receive(:send_message) do |target, message|
            expect(target.room).to eq('#baz')
            expect(message).to eq matchers[:project_destroyed]
          end
          subject.receive(request, response)
        end
      end
    end

    context 'when web project hook' do

      context 'when issue event' do
        let(:issue_payload) { fixture_file('web/issue') }
        before do
          allow(params).to receive(:[]).with('payload').and_return(issue_payload)
        end

        it 'notifies to the applicable rooms' do
          expect(robot).to receive(:send_message) do |target, message|
            expect(target.room).to eq('#baz')
            expect(message).to eq matchers[:issue_opened]
          end
          subject.receive(request, response)
        end
      end

      context 'when push event' do
        let(:push_payload) { fixture_file('web/push') }
        before do
          allow(params).to receive(:[]).with('payload').and_return(push_payload)
        end

        it 'notifies to the applicable rooms' do
          expect(robot).to receive(:send_message) do |target, message|
            expect(target.room).to eq('#baz')
            expect(message).to eq matchers[:add_to_branch]
          end
          subject.receive(request, response)
        end
      end

      context 'when merge request event' do
        let(:merge_request_payload) { fixture_file('web/merge_request') }
        before do
          allow(params).to receive(:[]).with('payload').and_return(merge_request_payload)
        end

        it 'notifies to the applicable rooms' do
          expect(robot).to receive(:send_message) do |target, message|
            expect(target.room).to eq('#baz')
            expect(message).to eq matchers[:merge_request_opened]
          end
          subject.receive(request, response)
        end
      end

      context 'when note on commit event' do
        let(:note_commit_payload) { fixture_file('web/note_commit') }
        before do
          allow(params).to receive(:[]).with('payload').and_return(note_commit_payload)
        end

        it 'notifies to the applicable rooms' do
          expect(robot).to receive(:send_message) do |target, message|
            expect(target.room).to eq('#baz')
            expect(message).to eq matchers[:note_on_commit]
          end
          subject.receive(request, response)
        end
      end

      context 'when note on issue event' do
        let(:note_issue_payload) { fixture_file('web/note_issue') }
        before do
          allow(params).to receive(:[]).with('payload').and_return(note_issue_payload)
        end

        it 'notifies to the applicable rooms' do
          expect(robot).to receive(:send_message) do |target, message|
            expect(target.room).to eq('#baz')
            expect(message).to eq matchers[:note_on_issue]
          end
          subject.receive(request, response)
        end
      end

      context 'when note on merge request event' do
        let(:note_merge_request_payload) { fixture_file('web/note_merge_request') }
        before do
          allow(params).to receive(:[]).with('payload').and_return(note_merge_request_payload)
        end

        it 'notifies to the applicable rooms' do
          expect(robot).to receive(:send_message) do |target, message|
            expect(target.room).to eq('#baz')
            expect(message).to eq matchers[:note_on_merge_request]
          end
          subject.receive(request, response)
        end
      end

      context 'when note on snippet event' do
        let(:note_snippet_payload) { fixture_file('web/note_snippet') }
        before do
          allow(params).to receive(:[]).with('payload').and_return(note_snippet_payload)
        end

        it 'notifies to the applicable rooms' do
          expect(robot).to receive(:send_message) do |target, message|
            expect(target.room).to eq('#baz')
            expect(message).to eq matchers[:note_on_snippet]
          end
          subject.receive(request, response)
        end
      end
    end
  end
end
