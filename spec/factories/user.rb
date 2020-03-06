FactoryBot.define do
	factory :user do
		name { "bingbong" }
		login { "abc" }
		email { "abc@hotmail.com" }
		user_type { 5 }
		id { 1 }
		persistence_token { "a" }
		single_access_token { "a" }
		perishable_token { "a" }
	end
end
