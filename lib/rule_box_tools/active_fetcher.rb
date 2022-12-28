# frozen_string_literal: true

module RuleBoxTools
  module ActiveFetcher
    def init_with(resource, start_with_relation: nil, **args)
      @resource = resource
      @args = args.with_indifferent_access
      @relation = start_with_relation || resource
    end

    def default_per_page
      10
    end

    def by_date
      start_date, end_date, period_type = query.values_at :start_date, :end_date, :period_type
      period_type = 'created_at' unless valid_period_type(period_type)

      @relation =
        if end_date.present? && start_date.present?
          start_date = start_date.to_datetime
          end_date = end_date.to_datetime
          relation.where("#{table_name}.#{period_type}" => start_date..end_date)
        elsif start_date.present?
          relation.where("#{table_name}.#{period_type} >= ?", start_date.to_datetime)
        elsif end_date.present?
          relation.where("#{table_name}.#{period_type} <= ?", end_date.to_datetime)
        else
          relation
        end
    end

    def valid_period_type(period_type)
      period_type.present? && columns.include?(period_type.to_s)
    end

    def by_equal_attributes(*attributes)
      condition = {}
      attributes.each do |key|
        condition["#{table_name}.#{key}"] = query[key] if query[key].present?
      end

      @relation = relation.where(condition)
    end

    def by_generic(*attributes)
      return self unless query[:generic].present?

      condition = attributes.map do |attribute|
        "#{table_name}.#{attribute} ILIKE :generic"
      end.join(' OR ')

      @relation = relation.where(condition, generic: "%#{query[:generic]}%")
    end

    def table_name
      @resource.table_name
    end

    def by_join_equal_attributes(join_name, *attributes)
      condition = {}
      table_name = join_name.to_s.pluralize
      attributes.each do |key|
        condition["#{table_name}.#{key}"] = query[key] if query[key].present?
      end
      @relation = relation.joins(join_name).where(condition)
    end

    def build
      { data: build_data, meta: build_meta }
    end

    def build_data
      @relation = relation.page(page).per(per_page)
    end

    def build_meta
      {
        total_count: relation.total_count,
        count: relation.count,
        total_pages: relation.total_pages,
        current_page: relation.current_page,
        prev_page: relation.prev_page,
        next_page: relation.next_page,
        per_page: per_page
      }
    end

    private

    def by_admin?
      @args[:admin] == true || @args[:admin] == 'true'
    end

    def relation
      @relation ||= @resource.all
    end

    def query
      @args[:query] || @args[:q] || {}
    end

    def page
      @page ||= @args[:page]
    end

    def per_page
      @per_page ||= @args[:per_page] || 10
    end
  end
end
