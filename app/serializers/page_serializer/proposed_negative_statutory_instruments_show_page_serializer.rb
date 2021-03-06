module PageSerializer
  class ProposedNegativeStatutoryInstrumentsShowPageSerializer < LaidThingShowPageSerializer
    # Initialise a Proposed Negative Statutory Instruments show page serializer.
    #
    # @param [ActionDispatch::Request] request the current request object.
    # @param [<Grom::Node>] proposed_negative_statutory_instrument a Grom::Node object of type ProposedNegativeStatutoryInstrumentPaper.
    # @param [Array<Hash>] data_alternates array containing the href and type of the alternative data urls
    def initialize(request: nil, proposed_negative_statutory_instrument:, data_alternates: nil)
      @proposed_negative_statutory_instrument = proposed_negative_statutory_instrument
      @following_statutory_instruments        = @proposed_negative_statutory_instrument.statutory_instrument_papers

      super(request: request, laid_thing: @proposed_negative_statutory_instrument, data_alternates: data_alternates)
    end

    private

    def meta
      super(title: title)
    end

    def title
      @proposed_negative_statutory_instrument.try(:proposedNegativeStatutoryInstrumentPaperName) || t('no_name')
    end

    def heading1_component
      ComponentSerializer::Heading1ComponentSerializer.new(heading_content).to_h
    end

    def heading_content
      {}.tap do |hash|
        hash[:subheading] = ContentDataHelper.content_data(content: 'proposed-negative-statutory-instruments.show.subheading', link: proposed_negative_statutory_instruments_path)
        hash[:heading] = title || t('no_name')
      end
    end

    def meta_info
      [].tap do |items|
        web_link = @laid_thing.try(:workPackagedThingHasWorkPackagedThingWebLink)
        items << create_description_list_item(term: 'laid-thing.web-link', descriptions: [link_to(web_link, web_link)]) if web_link
        items << create_description_list_item(term: 'laid-thing.laid-date', descriptions: [TimeHelper.time_translation(date_first: @laid_thing&.laying&.date)]) if @laid_thing&.laying&.date
        items << create_description_list_item(term: 'proposed-negative-statutory-instruments.show.preceding-title', descriptions: connected_statutory_instruments)
        items << create_description_list_item(term: 'laid-thing.laying-person', descriptions: [@laying_person&.display_name])
        items << create_description_list_item(term: 'laid-thing.laying-body', descriptions: [link_to(@laying_body.try(:groupName), group_path(@laying_body.graph_id))]) if @laying_body
      end.compact
    end

    def connected_statutory_instruments
      @following_statutory_instruments.map do |stat_instrument|
        link_to(stat_instrument.try(:statutoryInstrumentPaperName), statutory_instrument_path(stat_instrument.graph_id))
      end
    end
  end
end
