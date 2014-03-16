#encoding: utf-8
require "spec_helper"

module Mongoid
  describe MagicCounterCache do

    describe ".counter_cache" do

      context "when the document is associated without condition" do

        before do
          Library.delete_all
        end

        let(:library) do
          Library.new
        end

        let(:book) do
          Book.new
        end

        before do
          library.save
          library.books.create(:title => "War and Peace")
        end

        it "sets the target of the relation" do
          library.books.first.title.should == "War and Peace"
        end

        it "should have 1 book in books" do
          library.books.size.should == 1
        end

        it "should have 1 song in counter" do
          library.book_count.should == 1
        end

        it "should have book_count and relation count equal" do
          library.book_count.should == library.books.size
        end

        it "sets the counter cache equal to the relation count on addition" do
          5.times do |n|
            library.books << Book.new
            library.book_count.should == library.books.size
          end
        end

        it "should increase counter when new books are added" do
          library.books.push( book )
          library.books.size.should == 2
        end

        it "should increase counter when new books are added" do
          library.books.push( book )
          library.books.size.should == library.book_count
        end

        it "should increase counter when new books are added" do
          library.books.push( book )
          book.destroy
          library.books.size.should == 1
        end

        it "should increase counter when new books are added" do
          library.books.push( book )
          book.destroy
          library.books.size.should == library.book_count
        end

        it "decreases the counter cache when records are deleted" do
          library.book_count.should == library.books.entries.size
        end

        it "should by default use demodulized and underscored model names for the count field" do
          book = library.books.last
          book.foreign_publication_count.should == 0
          book.foreign_publications.push( Book::ForeignPublication.new )
          book.foreign_publication_count.should == 1
        end


        context "when the referenced document has an embedded document" do

          let(:page) do
            Page.new
          end

          before do
            book.save
            book.pages.create(:title => "it was a long and stormy night")
            library.books << book
          end

          it "should have 1 page in pages" do
            book.pages.size.should == 1
          end 

          it "should be accessible through parent" do
            library.books.last.pages.size.should == 1
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
          album.save
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

      context "when the field is specified directly in an associated context" do

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
          person.save
          person.feelings.create
        end

        it "should have 1 feeling in feelings" do
          person.feelings.size.should == 1
        end

        it "should have 1 feeling in counter" do
         person.all_my_feels.should == person.feelings.size
        end

        it "sets the counter cache equal to the relation count on addition" do
          5.times do |n|
            person.feelings.create
            person.feelings.size.should == person.all_my_feels
          end
        end
        it "decreases the counter cache when records are deleted" do
          person.feelings.push( feeling )
          feeling.destroy
          person.all_my_feels.should == person.feelings.size
        end
      end

      context "when the document is associated with condition" do

        before do
          Post.delete_all
        end

        let(:post) do
          Post.new
        end

        let(:comment) do
          Comment.new(:is_published => true)
        end

        before do
          post.save
          post.comments.create(:remark => "I agree with you", :is_published => true)
        end

        it "sets the target of the relation" do
          post.comments.first.remark.should == "I agree with you"
        end

        it "should have 1 comment for post" do
          post.comments.size.should == 1
        end

        it "should have 1 in comment counter" do
          post.comment_count.should == 1
        end

        it "sets the counter cache equal to the relation count on addition" do
          5.times do |n|
            post.comments << Comment.new(:is_published => true)
            post.comment_count.should == post.comments.size 
          end
        end

        it "should increase counter when new books are added" do
          post.comments.push( comment )
          post.comments.size.should == 2
        end

        it "should increase counter when new books are added" do
          post.comments.push( comment )
          post.comments.size.should == post.comment_count
        end

        it "should decrease counter when published comment is deleted" do
          post.comments.push( comment )
          comment.destroy
          post.comments.size.should == 1
        end

        it "should increase counter when new books are added" do
          post.comments.push( comment )
          comment.destroy
          post.comments.size.should == post.comment_count
        end

        it "shouldnot increase counter when unpublished comment is added" do
          post.comments << Comment.new
          post.comments.size.should == post.comment_count + 1
        end

        it "shouldnot decrease counter when unpublished comment is deleted" do
          post.comments << Comment.new(:remark => "2nd comment")
          post.comments << Comment.new(:remark => "3rd comment", :is_published => true)
          Comment.where(:remark == "2nd comment").first.destroy
          post.comment_count.should == 2
        end

        context "if update condition" do
          it "should not increase counter when old unpublished comment is published" do
            new_comment = Comment.new
            post.comments << new_comment
            post.comments.size.should == post.comment_count + 1

            new_comment.is_published.should == false
            new_comment.is_published = true
            new_comment.save!

            post.comments.size.should == post.comment_count + 1
          end

          it "should not decrease counter when old published comment is unpublished" do
            new_comment = Comment.new(:is_published => true)
            post.comments << new_comment
            post.comments.size.should == post.comment_count

            new_comment.is_published.should == true
            new_comment.is_published = false
            new_comment.save!

            post.comments.size.should == post.comment_count
          end

          it "should not modify counter when publish field is not dirty" do
            new_comment = Comment.new
            post.comments << new_comment
            post.comments.size.should == post.comment_count + 1

            new_comment.is_published.should == false
            new_comment.remark = 'New Remark'
            new_comment.save!

            post.comments.size.should == post.comment_count + 1
          end
        end
      end

      context "when the document is embedded and has condition for counter" do

        before do
          Article.delete_all
        end

        let(:article) do
          Article.new
        end

        let(:review) do
          Review.new(:comment => "This is nice article")
        end

        before do
          article.save
          article.reviews.create(:comment => "This is very good article", :is_published => true)
        end

        it "should have 1 review in reviews" do
          article.reviews.length.should == 1
        end

        it "should have correct comment" do
          article.reviews.first.comment.should == "This is very good article"
        end

        it "should have 1 review in counter" do
          article.review_count.should == 1
        end

        it "sets the counter cache equal to the relation count" do
          article.reviews.length.should == article.review_count
        end

        it "sets the counter cache equal to the relation count on addition" do
          5.times do |n|
            article.reviews << Review.new(:is_published => true)
            article.reviews.length.should == article.review_count
          end
        end

        it "decreases the counter cache when records are deleted" do
          article.reviews.all.destroy
          article.reviews.length.should == article.review_count
        end

        it "counter should not get incremented if condition is not meet" do
          5.times do |n|
            article.reviews << Review.new
          end
          article.reviews.length.should == 6 
          article.review_count.should == 1
        end

        context "if update condition" do
          it "should not increase counter when old unpublished review is published" do
            new_review = Review.new
            article.reviews << new_review
            article.reviews.size.should == article.review_count + 1

            new_review.is_published.should == false
            new_review.is_published = true
            new_review.save!

            article.reviews.size.should == article.review_count + 1
          end

          it "should not decrease counter when old published review is unpublished" do
            new_review = Review.new(:is_published => true)
            article.reviews << new_review
            article.reviews.size.should == article.review_count

            new_review.is_published.should == true
            new_review.is_published = false
            new_review.save!

            article.reviews.size.should == article.review_count
          end

          it "should not modify counter when published field is not dirty" do
            new_review = Review.new
            article.reviews << new_review
            article.reviews.size.should == article.review_count + 1

            new_review.is_published.should == false
            new_review.comment = 'New Comment'
            new_review.save!

            article.reviews.size.should == article.review_count + 1
          end
        end
      end
    end

    describe ".counter_cache with if_update" do

      context "when the document is associated with condition" do

        before do
          Post.delete_all
        end

        let(:post) do
          Post.new
        end

        let(:comment) do
          UpdateComment.new(:is_published => true)
        end

        before do
          post.save
          post.update_comments.create(:remark => "I agree with you", :is_published => true)
        end

        it "sets the target of the relation" do
          post.update_comments.first.remark.should == "I agree with you"
        end

        it "should have 1 comment for post" do
          post.update_comments.size.should == 1
        end

        it "should have 1 in comment counter" do
          post.update_comment_count.should == 1
        end

        it "sets the counter cache equal to the relation count on addition" do
          5.times do |n|
            post.update_comments << UpdateComment.new(:is_published => true)
            post.update_comment_count.should == post.update_comments.size
          end
        end

        it "should increase counter when new books are added" do
          post.update_comments.push( comment )
          post.update_comments.size.should == 2
        end

        it "should increase counter when new books are added" do
          post.update_comments.push( comment )
          post.update_comments.size.should == post.update_comment_count
        end

        it "should decrease counter when published comment is deleted" do
          post.update_comments.push( comment )
          comment.destroy
          post.update_comments.size.should == 1
        end

        it "should increase counter when new books are added" do
          post.update_comments.push( comment )
          comment.destroy
          post.update_comments.size.should == post.update_comment_count
        end

        it "shouldnot increase counter when unpublished comment is added" do
          post.update_comments << UpdateComment.new
          post.update_comments.size.should == post.update_comment_count + 1
        end

        it "shouldnot decrease counter when unpublished comment is deleted" do
          post.update_comments << UpdateComment.new(:remark => "2nd comment")
          post.update_comments << UpdateComment.new(:remark => "3rd comment", :is_published => true)
          UpdateComment.where(:remark == "2nd comment").first.destroy
          post.update_comment_count.should == 2
        end

        context "if update condition" do
          it "should increase counter when old unpublished comment is published" do
            new_comment = UpdateComment.new
            post.update_comments << new_comment
            post.update_comments.size.should == post.update_comment_count + 1

            new_comment.is_published.should == false
            new_comment.is_published = true
            new_comment.save!

            post.update_comments.size.should == post.update_comment_count

            new_comment.save! # Should not increment since is_published is not dirty.
            post.update_comments.size.should == post.update_comment_count
          end

          it "should decrease counter when old published comment is unpublished" do
            new_comment = UpdateComment.new(:is_published => true)
            post.update_comments << new_comment
            post.update_comments.size.should == post.update_comment_count

            new_comment.is_published.should == true
            new_comment.is_published = false
            new_comment.save!

            post.update_comments.size.should == post.update_comment_count + 1

            new_comment.save! # Should not increment since is_published is not dirty.
            post.update_comments.size.should == post.update_comment_count + 1
          end

          it "should not modify counter when publish field is not dirty" do
            new_comment = UpdateComment.new
            post.update_comments << new_comment
            post.update_comments.size.should == post.update_comment_count + 1

            new_comment.is_published.should == false
            new_comment.remark = 'New Remark'
            new_comment.save!

            post.update_comments.size.should == post.update_comment_count + 1
          end
        end
      end

      context "when the document is embedded and has condition for counter" do

        before do
          Article.delete_all
        end

        let(:article) do
          Article.new
        end

        let(:review) do
          UpdateReview.new(:comment => "This is nice article")
        end

        before do
          article.save
          article.update_reviews.create(:comment => "This is very good article", :is_published => true)
        end

        it "should have 1 review in reviews" do
          article.update_reviews.length.should == 1
        end

        it "should have correct comment" do
          article.update_reviews.first.comment.should == "This is very good article"
        end

        it "should have 1 review in counter" do
          article.update_review_count.should == 1
        end

        it "sets the counter cache equal to the relation count" do
          article.update_reviews.length.should == article.update_review_count
        end

        it "sets the counter cache equal to the relation count on addition" do
          5.times do |n|
            article.update_reviews << UpdateReview.new(:is_published => true)
            article.update_reviews.length.should == article.update_review_count
          end
        end

        it "decreases the counter cache when records are deleted" do
          article.update_reviews.all.destroy
          article.update_reviews.length.should == article.update_review_count
        end

        it "counter should not get incremented if condition is not meet" do
          5.times do |n|
            article.update_reviews << UpdateReview.new
          end
          article.update_reviews.length.should == 6
          article.update_review_count.should == 1
        end

        context "if update condition" do
          it "should increase counter when old unpublished review is published" do
            new_review = UpdateReview.new
            article.update_reviews << new_review
            article.update_reviews.size.should == article.update_review_count + 1

            new_review.is_published.should == false
            new_review.is_published = true
            new_review.save!

            article.update_reviews.size.should == article.update_review_count

            new_review.save! # Should not increment since is_published is not dirty.
            article.update_reviews.size.should == article.update_review_count
          end

          it "should decrease counter when old published review is unpublished" do
            new_review = UpdateReview.new(:is_published => true)
            article.update_reviews << new_review
            article.update_reviews.size.should == article.update_review_count

            new_review.is_published.should == true
            new_review.is_published = false
            new_review.save!

            article.update_reviews.size.should == article.update_review_count + 1

            new_review.save! # Should not decrement since is_published is not dirty.
            article.update_reviews.size.should == article.update_review_count + 1
          end

          it "should not modify counter when published field is not dirty" do
            new_review = UpdateReview.new
            article.update_reviews << new_review
            article.update_reviews.size.should == article.update_review_count + 1

            new_review.is_published.should == false
            new_review.comment = 'New Comment'
            new_review.save!

            article.update_reviews.size.should == article.update_review_count + 1
          end
        end
      end
    end

  end
end
