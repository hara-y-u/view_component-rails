# view_component-rails - ViewComponent for Rails [![Gem Version](https://badge.fury.io/rb/view_component-rails.svg)](http://badge.fury.io/rb/view_component-rails)

_WARNING: Development is still in alpha phase._

## Usage

Gemfile:

```ruby
gem 'view_component-rails'
```

Configuration:

```ruby
# config/initializers/view_component.rb
# Include helpers you want to use in component templates
ViewComponent.add_helper FontAwesome::Rails::IconHelper

ViewComponent.register 'comment'
# You can register nested directory:
# ViewComponent.register 'article/author'
```

File structure should be like below:

```
app/views/components
          |-- comment.rb # This is optional
          |-- comment
              |-- _show.slim
              |-- _info.slim
```

Template files sould be normal rails view file:

```slim
/ app/views/components/comment/_show.slim
.comment
  .comment__title= title
  .comment__body= body
  = render 'info', comment: comment
```

```slim
/ app/views/components/comment/_info.slim
ul.comment__info
  li.comment__info__item= comment.created_at
  li.comment__info__item= comment.user.name
```

Optionally, you can define ViewModel for the component:

```ruby
# This file is optional!
# app/views/components/comment.rb
class ViewComponent::Category
  class Comment < ViewComponent::ViewModel
    def title
      comment.title
    end

    def body
      comment.body
    end
  end
end
```
