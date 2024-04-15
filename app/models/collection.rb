# Container for Items
# Collections are set up as their own class because we do not want to
# intermix collections and items in the same table.  There are a much
# smaller number of collections that we want to manage separately for
# usability reasons.  It felt simpler to set up a separate table than
# to try to manage the distincion via scopes.
class Collection < Resource
end
