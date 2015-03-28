class PlsAccount < ActiveRecord::Base
  DATE_SCOPES = ['Today', 'Yesterday', 'This week', 'Last week', 'This month', 'Last month', 'All']

  belongs_to :user

  validates :name, presence: true, length: { minimum: 7 }, format: {
      with: /\A[a-z]+(?:[a-z0-9\-])*[a-z0-9]\z/,
      message: '只支持7位及7位长度以上，由小写字母、数字和横杠构成的名字。必须由小写字母开头，不能以横杠结尾。'
  }
  validates :key, presence: true

  before_create :generate_ogid

  scope :grouped_by_referrers, -> { select([:referrer, 'count(*) as count']).group(:referrer).order('count desc') }

  def generate_ogid
    self.ogid = SecureRandom.urlsafe_base64(10)
  end

  def self.filter(scope_name)
    return self if scope_name == 'All' || !scope_name.in?(DATE_SCOPES)

    date = case scope_name
             when 'Today'
               Date.today.beginning_of_day..Date.today.end_of_day
             when 'Yesterday'
               (Date.today - 1.day).beginning_of_day..(Date.today - 1.day).end_of_day
             when 'This week'
               Date.today.at_beginning_of_week.beginning_of_day..Date.today.end_of_day
             when 'Last week'
               1.week.ago.at_beginning_of_week..1.week.ago.at_end_of_week
             when 'This month'
               Date.today.at_beginning_of_month..Date.today
             when 'Last month'
               1.month.ago.at_beginning_of_month..1.month.ago.at_end_of_month
           end
    self.where(created_at: date)
  end

end
