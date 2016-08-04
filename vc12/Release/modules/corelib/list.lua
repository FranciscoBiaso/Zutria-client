function List()
  local out = {list = nil}
  
  out.add = function (item)
    out.list = { next = out.list, value = item}
  end
  
  out.del = function (item)
    local listReference = out.list
    local listPosition = out.list
    local listAntPosition = out.list
    while listPosition do
      if listPosition.value == item then
        if listAntPosition == listPosition then
            listPosition = listPosition.next
            listReference = listPosition
            listAntPosition.next = nil
            listAntPosition.value = nil
            listAntPosition = nil
        else
          listAntPosition.next = listPosition.next
          listPosition.next = nil
          listPosition.value = nil
          listPosition = nil
        end
        break
      end
      listAntPosition = listPosition
      listPosition = listPosition.next
    end
    
    out.list = listReference
  end

  out.print = function()
    local locallList = out.list
    while locallList do
      if locallList.value == nil then
        print(nil)
      else
        print(tostring(locallList.value))
      end
      locallList = locallList.next 
    end
  end
  
  out.getList = function()
    return out.list
  end
  
  out.getItem = function(item)
    local listReference = out.list
    local listPosition = out.list
    while listPosition do
      if listPosition.value == item then
        return item
      end
      listPosition = listPosition.next
    end
    return nil
  end
  
  return out
end


