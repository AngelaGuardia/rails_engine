class RevenueSerializer
  def self.revenue(rev)
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
