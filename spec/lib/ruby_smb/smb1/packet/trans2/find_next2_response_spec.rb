require 'spec_helper'

RSpec.describe RubySMB::SMB1::Packet::Trans2::FindNext2Response do

  subject(:packet) { described_class.new }

  describe '#smb_header' do
    subject(:header) { packet.smb_header }

    it 'is a standard SMB Header' do
      expect(header).to be_a RubySMB::SMB1::SMBHeader
    end

    it 'should have the command set to SMB_COM_NEGOTIATE' do
      expect(header.command).to eq RubySMB::SMB1::Commands::SMB_COM_TRANSACTION2
    end

    it 'should have the response flag set' do
      expect(header.flags.reply).to eq 1
    end
  end

  describe '#parameter_block' do
    subject(:parameter_block) { packet.parameter_block }

    it 'should have the setup set to the OPEN2 subcommand' do
      expect(parameter_block.setup).to include RubySMB::SMB1::Packet::Trans2::Subcommands::FIND_NEXT2
    end

  end

  describe '#data_block' do
    subject(:data_block) { packet.data_block }

    it { is_expected.to respond_to :name }
    it { is_expected.to respond_to :trans2_parameters }
    it { is_expected.to respond_to :trans2_data }

    it 'should keep #trans2_parameters 4-byte aligned' do
      expect(data_block.trans2_parameters.abs_offset % 4).to eq 0
    end

    it 'should keep #trans2_data 4-byte aligned' do
      expect(data_block.trans2_data.abs_offset % 4).to eq 0
    end

    describe '#trans2_parameters' do
      subject(:parameters) { data_block.trans2_parameters }

      it { is_expected.to respond_to :search_count }
      it { is_expected.to respond_to :eos }
      it { is_expected.to respond_to :ea_error_offset }
      it { is_expected.to respond_to :last_name_offset }
    end

    describe '#trans2_data' do
      subject(:data) { data_block.trans2_data }

      it { is_expected.to respond_to :buffer }
    end

  end

  describe '#results' do
    let(:names1) {
      names = RubySMB::Fscc::FileInformation::FileNamesInformation.new
      names.file_name = "test.txt"
      names.next_offset = names.do_num_bytes
      names
    }

    let(:names2) {
      names = RubySMB::Fscc::FileInformation::FileNamesInformation.new
      names.file_name = ".."
      names
    }

    let(:names_array) { [names1, names2 ]}

    let(:names_blob) { names_array.collect { |name| name.to_binary_s }.join('') }

    it 'returns an array of parsed Fileinformation structs' do
      packet.data_block.trans2_data.buffer = names_blob
      expect(packet.results(RubySMB::Fscc::FileInformation::FileNamesInformation)).to eq names_array
    end

  end

end