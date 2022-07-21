local function p(...)
	for i, v in pairs({...}) do
		print(v)
	end
end

local idk = 2

p("Hello World", idk, { "l", 23, "j"})