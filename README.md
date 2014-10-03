# view_component-rails - ViewComponent for Rails

_Development is still in alpha phase._

## Usage

File structure should be like below:

```
app/views/components
          |-- comment.rb
          |-- comment
              |-- _show.slim
              |-- _info.slim
```

Template files sould be normal rails view file:

```
# app/views/components/comment/_show.slim
.comment
  .comment__title= title
  .comment__body= body
  = render 'info', comment: comment
```

```
# app/views/components/comment/_info.slim
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
