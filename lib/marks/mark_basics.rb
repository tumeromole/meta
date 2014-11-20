module Marks
  class MarkBasics

    DEFAULT_MARKING_WEIGHT = 1.0  #for future use

    def new_mark(new_mark_name)
      Mark.create!({name: new_mark_name})
    end

    def wips_with_mark(mark_name)
      Wip.joins(:marks).where('marks.name = ?', mark_name)
    end

    #RUN ONCE
    def retroactively_convert_old_tags_to_new()
      tag_names = Wip::Tag.all.pluck(:name)
      unique_tag_sets = Product.all.uniq.pluck(:tags)
      unique_tag_sets.each do |u|
        tag_names = tag_names + u
      end
      tag_names.uniq!
      tag_names.each do |t|
        if Mark.find_by(name: t).nil?
          Mark.create!({name: t})
        end
      end
    end

    def retroactively_convert_old_wip_taggings_to_new()  #ALL OLD markingS ARE FOR WIPS
      taggings = Wip::Tagging.all
      taggings.each do |t|
        the_wip = t.wip
        name = t.tag.name
        mark_id = Mark.find_by(name: name).id
        if not Marking.where(mark_id: mark_id).where(markable_id: the_wip.id).present?
          Marking.create!({markable: the_wip, mark_id: mark_id, weight: DEFAULT_MARKING_WEIGHT})
        end
      end
    end

    def retroactively_convert_old_product_taggings_to_new()
      Product.all.each do |p|
        the_tags = p.tags
        if the_tags.count > 0
          the_tags.each do |t|
            the_mark = find_mark_from_name(t)
            if not the_mark.nil?
              if not Marking.where(mark_id: the_mark.id).where(markable_id: p.id).present?
                Marking.create!({markable: p, mark_id: the_mark.id, weight: DEFAULT_MARKING_WEIGHT})
              end
            end
          end
        end
      end
    end

    def retroactively_convert_old_system()
      retroactively_convert_old_tags_to_new()
      retroactively_convert_old_wip_taggings_to_new
      retroactively_convert_old_product_taggings_to_new()
    end


  end
end
