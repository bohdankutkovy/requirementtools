require 'spec_helper'


describe Attachment do

  it 'has a valid factory' do
    expect(FactoryGirl.build(:attachment)).to be_valid
  end

  let(:attachment){FactoryGirl.create(:attachment)}

  before :each do
    Attachment.destroy_all
  end

  describe 'Model validations' do
    it 'checks file size validation' do
      expect(FactoryGirl.build(:attachment, file: File.new('spec/fixtures/file/iu_mpi_report_public.pdf'))).to be_invalid
    end

    it 'checks file presence' do
      expect(FactoryGirl.build(:attachment, file: nil)).to be_invalid
    end


  end

  describe 'model methods' do
    it 'validates file size' do
      attachment.update_attributes(file: File.new('spec/fixtures/file/iu_mpi_report_public.pdf'))
      expect(attachment.file_size_validation).to include("should be less than 10MB")
    end

    it 'returns pure file name' do
      expect(attachment.name).to eq("pdf.pdf")
    end
  end


end

