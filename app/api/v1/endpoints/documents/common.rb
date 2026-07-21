# frozen_string_literal: true

module API::V1::Endpoints::Documents
  module Common
    extend Grape::API::Helpers

    DOCUMENTABLE_TYPES = %w(Truck Tank Trip Maintenance BillingStatement).freeze

    def document
      @document ||= find_kept!(::Document)
    end

    def document_params
      declared(params, include_missing: false).except(:id, :file)
    end

    def attach_file_if_present(document)
      return if params[:file].blank?

      document.file.attach(
        io: params[:file][:tempfile],
        filename: params[:file][:filename],
        content_type: params[:file][:type]
      )
    end
  end
end
