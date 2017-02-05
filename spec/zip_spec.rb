require './spec/spec_helper'

RSpec.describe Unzip do

  context 'validate uploaded file is a zip file' do

    let(:file) { File.open('./spec/assets/zip.zip') }
    let(:fake_zip) { File.open('./spec/assets/fake.zip') }
    let(:tarball) { File.open('./spec/assets/tarball.tgz') }
    let(:bad_name_zip) { File.open('./spec/assets/bad_name_zip') }
    let(:tempfile) { File.open("/tmp/zip.zip") }

    let(:params) {
      {
        file: {
          filename: "zip.zip",
          type: "application/zip",
          name: "file",
          tempfile: file,
          head: "Content-Disposition: form-data; name=\"file\"; filename=\"zip.zip\"\r\nContent-Type: application/zip\r\n"
        }
      }
    }

    let(:fake_zip_params) {
      {
        file: {
          filename: "fake.zip",
          type: "application/zip",
          name: "file",
          tempfile: fake_zip,
          head: "Content-Disposition: form-data; name=\"file\"; filename=\"zip.zip\"\r\nContent-Type: application/zip\r\n"
        }
      }
    }

    let(:tarball_params) {
      {
        file: {
          filename: 'tarball.tgz',
          type: 'application/x-compress-tar',
          name: 'file',
          tempfile: tarball,
          head: "Content-Disposition: form-data; name=\"file\"; filename=\"tarball.tgz\"\r\nContent-Type: application/x-compress-tar\r\n"
        }
      }
    }

    let(:bad_name_zip_params) {
      {
        file: {
          filename: 'bad_name_zip',
          type: 'application/octet-stream',
          name: 'file',
          tempfile: bad_name_zip,
          head: "Content-Disposition: form-data; name=\"file\"; filename=\"bad_name_zip\"\r\nContent-Type: application/octet-stream\r\n"
        }
      }
    }

    it 'should be valid when application/zip' do
      upload = Unzip.new(params[:file])
      expect(upload.file_type).to eq 'application/zip'
      expect(upload).to be_valid
    end

    it 'should be invalid if any other file type' do
      upload = Unzip.new(tarball_params[:file])
      expect(upload).to_not be_valid
    end

    it 'should be invalid if pretending to be zipfile' do
      upload = Unzip.new(fake_zip_params[:file])
      expect(upload).to_not be_valid
    end

    it "should be valid when the file suffix is '.zip'" do
      upload = Unzip.new(params[:file])
      expect(upload.ext_name).to eq '.zip'
      expect(upload).to be_valid
    end

    it "should be invalid if the file suffix is not '.zip'" do
      upload = Unzip.new(bad_name_zip_params[:file])
      expect(upload).to_not be_valid
    end
  end

  context 'unzipping files' do
    let(:pdf_dir) { File.open('./spec/assets/area.zip') }

    let(:pdf_dir_params) {
      {
        file: {
          filename: "area.zip",
          type: "application/zip",
          name: "file",
          tempfile: pdf_dir,
          head: "Content-Disposition: form-data; name=\"file\"; filename=\"area.zip\"\r\nContent-Type: application/zip\r\n"
        }
      }
    }

    before do
      @upload = Unzip.new(pdf_dir_params[:file])
    end

    it "should permit pdf files" do
      expect(@upload).to be_valid
      expect(@upload.saved_files.count).to eq 1
    end

    it 'should reject non-pdf files' do
      expect(@upload.rejected_files.count).to eq 4
    end
  end

  context 'unzipping archive full of pdfs' do
    let(:new_pdf_dir) { File.open('./spec/assets/pdfs.zip') }

    let(:new_pdf_dir_params) {
      {
        file: {
          filename: "pdfs.zip",
          type: "application/zip",
          name: "file",
          tempfile: new_pdf_dir,
          head: "Content-Disposition: form-data; name=\"file\"; filename=\"pdfs.zip\"\r\nContent-Type: application/zip\r\n"
        }
      }
    }

    it 'should permit all pdf files' do
      upload = Unzip.new(new_pdf_dir_params[:file])
      expect(upload).to be_valid
      expect(upload.saved_files.count).to eq 3
    end
  end

  context 'fake pdf files with correct headers/trailers' do
    let(:fake_pdf_zip) { File.open('./spec/assets/hack.zip') }

    let(:fake_pdf_zip_params) {
      {
        file: {
          filename: "hack.zip",
          type: "application/zip",
          name: "file",
          tempfile: fake_pdf_zip,
          head: "Content-Disposition: form-data; name=\"file\"; filename=\"hack.zip\"\r\nContent-Type: application/zip\r\n"
        }
      }
    }

    # This test fails because it passes validation but is actually a fake.
    # We need to work out how to ACTUALLY verify the validity of a pdf file.
    # Another method mentioned on stackoverflow is checking for /Page 1../Page 2...
    # But again, checking for string contents is not necessarily reliable as
    # can easily be faked by someone who knows what they are doing

    # When security is a major issue, we need to find a better method of validating uploaded files

    it 'should reject fake pdfs' do
      upload = Unzip.new(fake_pdf_zip_params[:file])
      expect(upload).to_not be_valid
      expect(upload.saved_files.count).tp eq 0
    end

  end

end
