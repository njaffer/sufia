module Sufia
  class FileSetActor < CurationConcerns::FileSetActor

    def create_metadata(upload_set_id, work, file_set_params = {})
      work ||= default_work
      super
    end

    private

      def default_work
        GenericWork.create.tap do |w|
          w.apply_depositor_metadata(user)
          w.title = ["Default title"]
          w.save
        end
      end
  end
end
