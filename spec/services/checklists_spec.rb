require 'rails_helper'

describe Checklists do
  describe described_class::Create do
    it 'raises error if required parameters are not provided' do
      expect { described_class.(name: nil) }.to raise_error ArgumentError
      expect { described_class.(name: Faker::Lorem.word, items: nil) }.to raise_error ArgumentError
      expect { described_class.(name: Faker::Lorem.word, items: []) }.to raise_error ArgumentError
    end

    it 'creates a new checklist in the system with items' do
      name = Faker::Lorem.word
      items = [
        { item: Faker::Lorem.sentence, help: Faker::Lorem.sentence },
        { item: Faker::Lorem.sentence, help: nil }
      ]

      checklist = described_class.(name: name, items: items)

      expect(checklist).to be
      expect(checklist.name_eng).to eq name
      expect(checklist.items.length).to eq 2
      expect(checklist.items[0].item_eng).to eq items[0][:item]
      expect(checklist.items[0].help_eng).to eq items[0][:help]
      expect(checklist.items[1].item_eng).to eq items[1][:item]
      expect(checklist.items[1].help_eng).to_not be
    end
  end

  describe described_class::Update do
    it 'raises error if required parameters are not provided' do
      expect { described_class.(checklist: nil, name: Faker::Lorem.word) }.to raise_error ArgumentError
      expect { described_class.(checklist: create(:checklist), name: nil) }.to raise_error ArgumentError
    end

    it 'updates the name of the checklist' do
      checklist = create_checklist_english
      checklist_item = checklist.items[0]
      checklist_item_count = checklist.items.length
      old_name = checklist.name_eng
      new_name = old_name + Faker::Lorem.word

      updated_checklist = described_class.(name: new_name, checklist: checklist)

      expect(updated_checklist.id).to eq checklist.id
      expect(updated_checklist.name_eng).to eq new_name
      expect(updated_checklist.name_eng).to_not eq old_name
      expect(updated_checklist.items.length).to eq checklist_item_count
      expect(updated_checklist.items[0].id).to eq checklist_item.id
      expect(updated_checklist.items[0].item_eng).to eq checklist_item.item_eng
      expect(updated_checklist.items[0].help_eng).to eq checklist_item.help_eng
    end
  end

  describe described_class::AddTranslation do
    let!(:checklist) { create_checklist_english }
    let!(:checklist_item_1) { checklist.items[0] }
    let!(:checklist_item_2) { checklist.items[1] }
    let!(:name) { Faker::Lorem.word }
    let!(:language) { :fre.to_s }
    let!(:another_language) { :esp.to_s }
    let!(:items) { [{ item: Faker::Lorem.sentence, help: Faker::Lorem.sentence },
                    { item: Faker::Lorem.sentence, help: nil }] }

    it 'raises error if required parameters are not provided' do
      expect { described_class.(checklist: checklist, items: items, name: name, language: language) }.not_to raise_error
      expect { described_class.(checklist: nil, items: items, name: name, language: language) }.to raise_error ArgumentError
      expect { described_class.(checklist: checklist, items: items, name: nil, language: language) }.to raise_error ArgumentError
      expect { described_class.(checklist: checklist, items: nil, name: name, language: language) }.to raise_error ArgumentError
      expect { described_class.(checklist: checklist, items: [], name: name, language: language) }.to raise_error ArgumentError
      expect { described_class.(checklist: checklist, items: items, name: name, language: nil) }.to raise_error ArgumentError
    end

    it 'raises error if checklist has already been translated in specified language' do
      described_class.(checklist: checklist, items: items, name: name, language: language)
      expect { described_class.(checklist: checklist, items: items, name: name, language: language) }.to raise_error ServiceError
      expect { described_class.(checklist: checklist, items: items, name: name, language: another_language) }.not_to raise_error
    end

    it 'raises error if item count does not match' do
      expect { described_class.(checklist: checklist, items: [items[0]], name: name, language: language) }.to raise_error ServiceError
    end

    it 'adds translation of the specified checklist and its items' do
      described_class.(checklist: checklist, items: items, name: name, language: language)
      checklist.reload
      expect(checklist.with_translation(language).name).to eq name
      expect(checklist.with_translation(another_language)).to_not be
      expect(checklist.items[0].with_translation(language).item).to be
      expect(checklist.items[0].with_translation(language).help).to be
      expect(checklist.items[1].with_translation(language).item).to be
      expect(checklist.items[1].with_translation(language).help).to_not be
    end
  end

  describe described_class::UpdateTranslation do
    let!(:checklist) { create_checklist_english }
    let!(:checklist_item_1) { checklist.items[0] }
    let!(:checklist_item_2) { checklist.items[1] }
    let!(:name) { Faker::Lorem.word }
    let!(:language) { :fre.to_s }
    let!(:items) { [{ item: Faker::Lorem.sentence, help: Faker::Lorem.sentence },
                    { item: Faker::Lorem.sentence, help: nil }] } 
    let!(:other_language) { :esp.to_s }
    
    before do
      Checklists::AddTranslation.(checklist: checklist, name: name, items: items, language: language)
    end

    it 'raises error if required parameters are not provided' do
      expect { described_class.(checklist: nil, name: name, language: language) }.to raise_error ArgumentError
      expect { described_class.(checklist: checklist, name: nil, language: language) }.to raise_error ArgumentError
      expect { described_class.(checklist: checklist, name: name, language: nil) }.to raise_error ArgumentError
    end

    it 'raises error if translation does not exist' do
      expect { described_class.(checklist: checklist, name: name, language: other_language) }.to raise_error ServiceError
    end

    it 'updates the name of the checklist translation' do
      old_eng_name = checklist.name_eng
      old_name = checklist.with_translation(language).name
      new_name = old_name + Faker::Lorem.word
      checklist_item_count = checklist.items.length

      updated_checklist = described_class.(name: new_name, checklist: checklist, language: language)

      expect(updated_checklist.id).to eq checklist.id
      expect(updated_checklist.name_eng).to eq old_eng_name
      expect(updated_checklist.with_translation(language).name).to eq new_name
      
      expect(updated_checklist.items.length).to eq checklist_item_count
      
      expect(updated_checklist.items[0].id).to eq checklist_item_1.id
      expect(updated_checklist.items[0].item_eng).to eq checklist_item_1.item_eng
      expect(updated_checklist.items[0].help_eng).to eq checklist_item_1.help_eng
      
      expect(updated_checklist.items[1].id).to eq checklist_item_2.id
      expect(updated_checklist.items[1].item_eng).to eq checklist_item_2.item_eng
      expect(updated_checklist.items[1].help_eng).to eq checklist_item_2.help_eng
      
      expect(updated_checklist.items[0].with_translation(language).item).to eq items[0][:item]
      expect(updated_checklist.items[0].with_translation(language).help).to eq items[0][:help]
      
      expect(updated_checklist.items[1].with_translation(language).item).to eq items[1][:item]
      expect(updated_checklist.items[1].with_translation(language).help).to eq items[1][:help]
      
    end
  end

  describe described_class::RemoveTranslation do
    let!(:checklist) { create_checklist_english }
    let!(:checklist_item_1) { checklist.items[0] }
    let!(:checklist_item_2) { checklist.items[1] }
    let!(:name) { Faker::Lorem.word }
    let!(:other_name) { Faker::Lorem.word }
    let!(:language) { :fre.to_s }
    let!(:other_language) { :esp.to_s }
    let!(:items) { [{ item: Faker::Lorem.sentence, help: Faker::Lorem.sentence },
                    { item: Faker::Lorem.sentence, help: nil }] } 
    let!(:other_items) { [{ item: Faker::Lorem.sentence, help: Faker::Lorem.sentence },
                          { item: Faker::Lorem.sentence, help: nil }] } 
    before do
      Checklists::AddTranslation.(checklist: checklist, name: name, items: items, language: language)
      Checklists::AddTranslation.(checklist: checklist, name: other_name, items: other_items, language: other_language)
    end
    
    it 'raises error if required parameters are not provided' do
      expect { described_class.(checklist: checklist, language: language) }.not_to raise_error
      expect { described_class.(checklist: nil, language: language) }.to raise_error ArgumentError
      expect { described_class.(checklist: checklist, language: nil) }.to raise_error ArgumentError
    end

    it 'raises error if translation does not exist in specified language' do
      expect { described_class.(checklist: checklist, language: 'deu') }.to raise_error ServiceError
    end

    it 'removes translation in specified language' do
      described_class.(checklist: checklist, language: language)
      
      expect(checklist.with_translation(language)).to_not be
      expect(checklist.with_translation(other_language)).to be

      expect(checklist_item_1.with_translation(language)).to_not be
      expect(checklist_item_2.with_translation(language)).to_not be
      expect(checklist_item_1.with_translation(other_language)).to be
      expect(checklist_item_2.with_translation(other_language)).to be

    end
  end

  describe described_class::Enable do
    context 'missing checklist' do
      it 'raises error if required parameters are not provided' do
        expect { described_class.(checklist: nil) }.to raise_error ArgumentError
      end
    end

    context 'enabled checklist' do
      let!(:checklist) { create_checklist_english }

      it 'does nothing' do
        expect(checklist.enabled?).to eq true
        described_class.(checklist: checklist)
        checklist.reload
        expect(checklist.enabled?).to eq true
      end
    end

    context 'disabled checklist' do
      let!(:checklist) { create_checklist_english }
      
      before do 
        Globalize.with_locale :eng do
          checklist.enabled = false
          checklist.save!
        end
      end

      it 'marks the checklist as enabled' do
        expect(checklist.enabled?).to eq false
        described_class.(checklist: checklist)
        checklist.reload
        expect(checklist.enabled?).to eq true
      end
    end
  end

  describe described_class::Disable do
    context 'missing checklist' do
      it 'raises error if required parameters are not provided' do
        expect { described_class.(checklist: nil) }.to raise_error ArgumentError
      end
    end

    context 'disabled checklist' do
      let!(:checklist) { create_checklist_english }
      
      before do 
        Globalize.with_locale :eng do
          checklist.enabled = false
          checklist.save!
        end
      end

      it 'does nothing' do
        expect(checklist.enabled?).to eq false
        described_class.(checklist: checklist)
        checklist.reload
        expect(checklist.enabled?).to eq false
      end
    end

    context 'enabled checklist' do
      let!(:checklist) { create_checklist_english }

      it 'marks the checklist as enabled' do
        expect(checklist.enabled?).to eq true
        described_class.(checklist: checklist)
        checklist.reload
        expect(checklist.enabled?).to eq false
      end
    end
  end
end