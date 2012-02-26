#encoding: utf-8
require "spec_helper"

module Mongoid
  describe CounterCache do

    describe ".counter_cache" do

      context "when the document is associated" do
        before do
          Library.delete_all
          Book.delete_all
        end
        let(:library) do
          Library.new
        end

        let(:book) do
          Book.new
        end

        before do
          library.books = [ book ]
        end

        it "sets the target of the relation" do
          library.books.should == [ book ]
        end

        it "should have 1 book in books" do
          library.books.count.should == 1
        end

        it "should have 1 song in counter" do
          library.books.count.should == library.book_count
        end

        it "sets the counter cache equal to the relation count on addition" do
          5.times do |n|
            library.books << Book.new
            library.books.count.should == library.book_count
          end
        end
        it "decreases the counter cache when records are deleted" do
          library.books.delete_all
          library.books.count.should == 0
        end
        it "decreases the counter cache when records are deleted" do
          library.books.delete_all
          library.books.count.should == library.book_count
        end

        context "when the referenced document has an embedded document" do

          let(:page) do
            Page.new
          end

          before do
            book.pages.create(:title => "it was a long and stormy night")
          end

          it "should have 1 page in pages" do
            book.pages.length.should == 1
          end 

          it "should be accessible through parent" do
            library.books.first.pages.length.should == 1
          end

          it "should have 1 page in counter" do
            book.pages.length.should == book.page_count
          end

          it "should increase with additional pages" do
            20.times do |n|
              book.pages.create()
              book.pages.length.should == book.page_count
            end
          end

          it "should decrease the counter when records are deleted" do
            book.pages.all.destroy
            book.pages.length.should == book.page_count
          end
        end

      end
      context "when the document is embedded" do

        before do
          Album.delete_all
        end

        let(:album) do
          Album.new
        end

        let(:song) do
          Song.new(:title => "love song")
        end

        before do
          album.songs.create(:title => "create you a song")
        end

        it "should have 1 song in songs" do
          album.songs.length.should == 1
        end

        it "should have correct title" do
          album.songs.first.title.should == "create you a song"
        end

        it "should have 1 song in counter" do
          album.song_count.should == 1
        end

        it "sets the counter cache equal to the relation count" do
          album.songs.length.should == album.song_count
        end

        it "sets the counter cache equal to the relation count on addition" do
          5.times do |n|
            album.songs << Song.new
            album.songs.length.should == album.song_count
          end
        end
        it "decreases the counter cache when records are deleted" do
          album.songs.all.destroy
          album.songs.length.should == album.song_count
        end
      end

      context "when the field is specified directly" do
        before do
          Person.delete_all
        end
        
        let(:person) do
          Person.new
        end
        
        let(:feeling) do
          Feeling.new
        end

        before do
          person.feelings = [ feeling ]
        end

        it "should association relation correctly" do
          person.feelings == [ feeling ]
        end

        it "should have 1 feeling in feelings" do
          person.feelings.length.should == 1
        end

        it "should have 1 feeling in counter" do
         person.feelings.length.should == person.all_my_feels 
        end
      end
    end

  end
end
