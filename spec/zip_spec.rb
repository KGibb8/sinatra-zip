require './spec/spec_helper'

RSpec.describe Unzip do

  let(:file) { File.open('./spec/assets/zip.zip') }
  let(:fake_zip) { File.open('./spec/assets/fake.zip') }
  let(:tarball) { File.open('./spec/assets/tarball.tgz') }
  let(:bad_name_zip) { File.open('./spec/assets/bad_name_zip') }
  let(:tempfile) { File.open("/tmp/zip.zip") }

  let(:params) {
    { file: {
        filename: "zip.zip",
        type: "application/zip",
        name: "file",
        tempfile: file,
        head: "Content-Disposition: form-data; name=\"file\"; filename=\"zip.zip\"\r\nContent-Type: application/zip\r\n"
      }
    }
  }

  let(:fake_zip_params) {
    { file: {
        filename: "fake.zip",
        type: "application/zip",
        name: "file",
        tempfile: fake_zip,
        head: "Content-Disposition: form-data; name=\"file\"; filename=\"zip.zip\"\r\nContent-Type: application/zip\r\n"
      }
    }
  }

  let(:tarball_params) {
    { file: {
        filename: 'tarball.tgz',
        type: 'application/x-compress-tar',
        name: 'file',
        tempfile: tarball,
        head: "Content-Disposition: form-data; name=\"file\"; filename=\"tarball.tgz\"\r\nContent-Type: application/x-compress-tar\r\n"
      }
    }
  }

  let(:bad_name_zip_params) {
    { file: {
        filename: 'bad_name_zip',
        type: 'application/octet-stream',
        name: 'file',
        tempfile: bad_name_zip,
        head: "Content-Disposition: form-data; name=\"file\"; filename=\"bad_name_zip\"\r\nContent-Type: application/octet-stream\r\n"
      }
    }
  }

  # it 'should be valid when application/zip' do
  #   upload = Unzip.new(params[:file])
  #   expect(upload.file_type).to eq 'application/zip'
  #   expect(upload).to be_valid
  # end

  # it 'should be invalid if any other file type' do
  #   upload = Unzip.new(tarball_params[:file])
  #   expect(upload).to_not be_valid
  # end

  # it 'should be invalid if pretending to be zipfile' do
  #   upload = Unzip.new(fake_zip_params[:file])
  #   expect(upload).to_not be_valid
  # end

  # it "should be valid when the file suffix is '.zip'" do
  #   upload = Unzip.new(params[:file])
  #   expect(upload.ext_name).to eq '.zip'
  #   expect(upload).to be_valid
  # end

  # it "should be invalid if the file suffix is not '.zip'" do
  #   upload = Unzip.new(bad_name_zip_params[:file])
  #   expect(upload).to_not be_valid
  # end

  let(:pdf_dir) { File.open('./spec/assets/pdfs.zip') }

  let(:pdf_dir_params) {
    { file: {
        filename: "pdfs.zip",
        type: "application/zip",
        name: "file",
        tempfile: pdf_dir,
        head: "Content-Disposition: form-data; name=\"file\"; filename=\"area.zip\"\r\nContent-Type: application/zip\r\n"
      }
    }
  }

  it "should be permit validation of pdf files" do
    upload = Unzip.new(pdf_dir_params[:file])
    expect(upload).to be_valid
    expect(upload.files.count).to eq 3
  end

  # it "should unpack the zip file into a directory" do

  # end

end
