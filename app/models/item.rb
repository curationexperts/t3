# Basic repository object, smallest unit of discovery
# We want Items and Collections to share as much behavior as possible for
# usability reasons - i.e. once we know how to manage an item, it should
# be an easy jump to managing collections.  So both classes inherit from the
# same parent and share controllers that provide common behavior
class Item < Resource
end
