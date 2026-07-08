# frozen_string_literal: true

module API::V1::Entities
  class BillingStatement < Base
    expose :id,           documentation: {type: "Integer", desc: "The ID of the statement."}
    expose :number,       documentation: {type: "String",  desc: "The statement number."}
    expose :status,       documentation: {type: "String",  desc: "The statement status (draft, issued, paid)."}
    expose :month,        documentation: {type: "Date",    desc: "The month the statement covers."}
    expose :starts_on,    documentation: {type: "Date",    desc: "The first day covered by the statement."}
    expose :ends_on,      documentation: {type: "Date",    desc: "The last day covered by the statement."}
    expose :issued_on,    documentation: {type: "Date",    desc: "The date the statement was issued."}
    expose :due_on,       documentation: {type: "Date",    desc: "The date payment is due."}
    expose :total_amount, documentation: {type: "Float",   desc: "The total amount before tax."}
    expose :total_tva,    documentation: {type: "Float",   desc: "The total tax (TVA)."}
    expose :grand_total,  documentation: {type: "Float",   desc: "The grand total including tax."}
  end
end
