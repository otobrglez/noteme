require "spec_helper"

describe App do
  include Rack::Test::Methods

  before { Note.delete_all } #TODO: Add database_cleaner someday

  let(:app) { App }

  context "GET /" do
    subject { get '/' }
    its(:status){ should eq 200 }
  end

  context "notes" do
    context "GET /notes" do
      before do
        Note.create content: "Hellow"
        Note.create content: "World"
      end

      it { Note.should have(2).record }
      subject { get '/notes' }
      its(:status) { should eq 200 }
      its(:body){ should_not be_nil }
      let(:json) { MultiJson.load subject.body }
      it "should have 2 records in response" do
        json.size.should eq 2
      end
    end

    context "DELETE /notes/:id" do
      before { Note.delete_all }
      let(:note) { Note.create content: "This is content."}
      it "should have 1 record" do
        note.id.should_not be_nil
      end

      subject { delete "/notes/#{note.id}" }
      its(:status) { should eq 200 }
      it { Note.should have(0).records }
    end

    context "POST /notes (valid)" do
      before { Note.delete_all }
      let(:note_attributes) { Note.new(content: "What").attributes.except("id","created_at","updated_at") }
      subject { post '/notes', {note: note_attributes}}
      its(:status){ should eq 201 }
    end

    context "POST /notes (invalid)" do
      before { Note.delete_all }
      let(:note_attributes){{}}
      subject { post '/notes', {note: note_attributes}}
      its(:status){ should eq 400}
      let(:json){ MultiJson.load subject.body }
      it { json["errors"].should_not be_nil }
    end

    context "PUT /notes/:id" do
      before { Note.delete_all }
      let(:note_a) { Note.create(content: "LOL") }
      it "should return content on GET /:id" do
        get "/notes/#{note_a.id}"
        last_response.status.should eq 200
      end

      it "should update record PUT /:id" do
        Note.find(note_a.id).completed.should be 0
        put "/notes/#{note_a.id}", {note: {completed: 1}}
        last_response.status.should eq 200
        Note.find(note_a.id).completed.should be 1
      end
    end
  end

end

