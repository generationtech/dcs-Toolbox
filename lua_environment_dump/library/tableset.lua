-- turn a simple list into a key/value true table for future lookups
return function tableset(t)
  local u = { }
  for _, v in ipairs(t) do u[v] = true end
  return u
end
