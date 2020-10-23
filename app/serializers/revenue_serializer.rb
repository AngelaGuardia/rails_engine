class RevenueSerializer
  def self.revenue_over_range(rev)
    {
      "data":
      {
        "id": nil,
        "attributes":
        {
          "revenue": rev
        }
      }
    }
  end
end
