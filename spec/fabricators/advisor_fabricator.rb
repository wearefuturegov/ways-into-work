Fabricator(:advisor) do
  name { "#{FFaker::Name.first_name} #{FFaker::Name.last_name}"}
  login(fabricator: :user_login)
end
