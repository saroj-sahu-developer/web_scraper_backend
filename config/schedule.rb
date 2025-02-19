every 1.day, at: '3:00 am' do
  runner "UpdateOldProductsJob.perform_now"
end

