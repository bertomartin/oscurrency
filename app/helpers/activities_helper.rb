module ActivitiesHelper

  # Given an activity, return a message for the feed for the activity's class.
  def feed_message(activity)
    person = activity.person
    case activity_type(activity)
    when "BlogPost"
      post = activity.item
      blog = post.blog
      view_blog = blog_link("View #{h person.name}'s blog", blog)
      %(#{person_link(person)} made a blog post titled
        #{post_link(blog, post)}.<br /> #{view_blog}.)
    when "Comment"
      parent = activity.item.commentable
      parent_type = parent.class.to_s
      case parent_type
      when "BlogPost"
        post = activity.item.commentable
        blog = post.blog
        %(#{person_link(person)} made a comment to
           #{someones(blog.person, person)}
           blog post #{post_link(blog, post)}.)
      when "Person"
        %(#{person_link(activity.item.commenter)} commented on 
          #{wall(activity)}.)
      when "Event"
        event = activity.item.commentable
        commenter = activity.item.commenter
        %(#{person_link(commenter)} commented on 
          #{someones(event.person, commenter)} event: 
          #{event_link(event.title, event)}.)
      end
    when "Connection"
      %(#{person_link(activity.item.person)} and
        #{person_link(activity.item.contact)}
        have connected.)
    when "ForumPost"
      post = activity.item
      %(#{person_link(person)} made a post on the forum topic
        #{topic_link(post.topic)}.)
    when "Topic"
      %(#{person_link(person)} created the new discussion topic
        #{topic_link(activity.item)}.)
    when "Photo"
      %(#{person_link(person)}'s profile picture has changed.)
    when "Person"
      %(#{person_link(person)}'s description has changed.)
    when "Group"
      %(#{person_link(person)} created the group '#{group_link(Group.find(activity.item))}')
    when "Membership"
      %(#{person_link(person)} joined the group '#{group_link(Group.find(activity.item.group))}')
    when "Event"
      event = activity.item
      %(#{person_link(person)} has created a new event: #{event_link(event.title, event)}.)
    when "EventAttendee"
      event = activity.item.event
      %(#{person_link(person)} is attending #{someones(event.person, person)} event: 
        #{event_link(event.title, event)}.) 
    when "Req"
      req = activity.item
      %(#{person_link(person)} has created a new request: #{req_link(req.name, req)}.)
    when "Offer"
      offer = activity.item
      %(#{person_link(person)} has created a new offer: #{offer_link(offer.name, offer)}.)
    when "Exchange"
      exchange = activity.item
      if exchange.group.nil?
        %(#{person_link(person)} earned #{exchange.amount} hours for #{metadata_link(exchange.metadata)}.)
      else
        %(#{person_link(person)} earned #{exchange.amount} #{exchange.group.unit} for #{metadata_link(exchange.metadata)} in #{group_link(exchange.group)}.)
      end
    else
      raise "Invalid activity type #{activity_type(activity).inspect}"
    end
  end
  
  def minifeed_message(activity)
    person = activity.person
    case activity_type(activity)
    when "BlogPost"
      post = activity.item
      blog = post.blog
      raw %(#{h person.name} made a
        #{post_link("new blog post", blog, post)}.)
    when "Comment"
      parent = activity.item.commentable
      parent_type = parent.class.to_s
      case parent_type
      when "BlogPost"
        post = activity.item.commentable
        blog = post.blog
        raw %(#{h person.name} made a comment on
          #{someones(blog.person, person)} 
          #{post_link("blog post", post.blog, post)}.)
      when "Person"
        raw %(#{h activity.item.commenter.name} commented on 
          #{wall(activity)}.)
      when "Event"
        event = activity.item.commentable
        raw %(#{h activity.item.commenter.name} commented on 
          #{someones(event.person, activity.item.commenter)} #{event_link("event", event)}.)
      end
    when "Connection"
      raw %(#{h person.name} and #{activity.item.contact.name}
        have connected.)
    when "ForumPost"
      topic = activity.item.topic
      raw %(#{h person.name} made a #{topic_link("forum post", topic)}.)
    when "Topic"
      raw %(#{h person.name} created a 
        #{topic_link("new discussion topic", activity.item)}.)
    when "Photo"
      %(#{h person.name}'s profile picture has changed.)
    when "Person"
      %(#{h person.name}'s description has changed.)
    when "Group"
      raw %(#{h person.name} created the group '#{group_link(Group.find(activity.item))}')
    when "Membership"
      raw %(#{h person.name} joined the group '#{group_link(Group.find(activity.item.group))}')
    when "Event"
      raw %(#{h person.name}s has created a new #{event_link("event", activity.item)}.)
    when "EventAttendee"
      event = activity.item.event
      raw %(#{h person.name} is attending #{someones(event.person, person)} #{event_link("event", event)}.)
    when "Req"
      req = activity.item
      raw %(#{h person.name} has created a new request: #{req_link(req.name, req)}.)
    when "Offer"
      offer = activity.item
      raw %(#{h person.name} has created a new offer: #{offer_link(offer.name, offer)}.)
    when "Exchange"
      exchange = activity.item
      raw %(#{person.name} earned #{exchange.amount} #{exchange.group.unit} for #{metadata_link(exchange.metadata)} in #{group_link(exchange.group)}.)
    else
      raise "Invalid activity type #{activity_type(activity).inspect}"
    end
  end
  
  # Given an activity, return the right icon.
  def feed_icon(activity)
    img = case activity_type(activity)
            when "BlogPost"
              "blog.gif"
            when "Comment"
              parent_type = activity.item.commentable.class.to_s
              case parent_type
              when "BlogPost"
                "comment.gif"
              when "Event"
                "comment.gif"
              when "Person"
                "signal.gif"
              end
            when "Connection"
              "switch.gif"
            when "ForumPost"
              "new.gif"
            when "Topic"
              "add.gif"
            when "Photo"
              "camera.gif"
            when "Person"
              "edit.gif"
            when "Group"
              "new.gif"
            when "Membership"
              "add.gif"
            when "Event"
              "time.gif"
            when "EventAttendee"
              "check.gif"
            when "Req"
              "new.gif"
            when "Offer"
              "new.gif"
            when "Exchange"
              "favorite.gif"
            else
              raise "Invalid activity type #{activity_type(activity).inspect}"
            end
    image_tag("icons/#{img}", :class => "icon")
  end
  
  def someones(person, commenter, link = true)
    link ? "#{person_link(person)}'s" : "#{h person.name}'s"
  end
  
  def blog_link(text, blog)
    link_to(h(text), blog_path(blog))
  end
  
  def post_link(text, blog, post = nil)
    if post.nil?
      post = blog
      blog = text
      text = post.title
    end
    link_to(h(text), blog_post_path(blog, post))
  end
  
  def topic_link(text, topic = nil)
    if topic.nil?
      topic = text              # Eh?  This makes no sense...
      text = topic.name
    end
    link_to(h(text), forum_topic_path(topic.forum, topic), :class => "show-follow")
  end

  def event_link(text, event)
    link_to(h(text), event_path(event))
  end

  def metadata_link(metadata)
    if metadata.nil?
      "unknown!" # this should never happen.
    elsif metadata.class == Req
      link_to(h(metadata.name), req_path(metadata), :class => "show-follow")
    else
      link_to(h(metadata.name), offer_path(metadata), :class => "show-follow")
    end
  end

  def req_link(text, req)
    link_to(h(text), req_path(req), :class => "show-follow")
  end

  def offer_link(text, offer)
    link_to(h(text), offer_path(offer), :class => "show-follow")
  end

  # Return a link to the wall.
  def wall(activity)
    commenter = activity.person
    person = activity.item.commentable
    link_to("#{someones(person, commenter, false)} wall",
            person_path(person, :anchor => "wall"))
  end
  
  private
  
    # Return the type of activity.
    # We switch on the class.to_s because the class itself is quite long
    # (due to ActiveRecord).
    def activity_type(activity)
      activity.item.class.to_s      
    end
end
