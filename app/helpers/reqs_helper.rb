module ReqsHelper
  def accepted_messages(req)
    bids = req.bids.find_all {|bid| bid.accepted_at != nil}
    messages = bids.map {|bid| "Accepted bid from #{person_link bid.person} at #{time_ago_in_words(bid.accepted_at)} #{t('ago')}"}
  end

  def commitment_messages(req)
    bids = req.bids.find_all {|bid| bid.committed_at != nil}
    messages = bids.map {|bid| "Commitment by #{person_link bid.person} made #{time_ago_in_words(bid.committed_at)} #{t('ago')}"}
  end

  def completed_messages(req)
    bids = req.bids.find_all {|bid| bid.completed_at != nil}
    messages = bids.map {|bid| "Marked completed by #{person_link bid.person} #{time_ago_in_words(bid.completed_at)} #{t('ago')}"}
  end

  def approved_messages(req)
    bids = req.bids.find_all {|bid| bid.approved_at != nil}
    messages = bids.map {|bid| "Confirmed completed by #{person_link req.person} #{time_ago_in_words(bid.approved_at)} #{t('ago')}"}
  end

  def formatted_req_categories(categories)
    text = ""
    categories.each {|c| text << c + "<br>"}
    text.html_safe
  end
end
