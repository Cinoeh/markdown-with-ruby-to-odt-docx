local function esc(s)
  return s:gsub('&','&amp;'):gsub('<','&lt;'):gsub('>','&gt;'):gsub('"','&quot;')
end

local function process_ruby(el)
  local new_content = {}
  local i = 1
  while i <= #el.content do
    local item = el.content[i]
    if item.t == 'RawInline' and item.format == 'html' and item.text == '<ruby>' then
      local base_parts = {}
      local ruby_parts = {}
      local state = 'base'
      local j = i + 1
      local found_end = false

      while j <= #el.content do
        local next_item = el.content[j]
        if next_item.t == 'RawInline' and next_item.format == 'html' then
          if next_item.text == '<rt>' then
            state = 'ruby'
          elseif next_item.text == '</ruby>' then
            found_end = true
            break
          end
        elseif next_item.t == 'Str' then
          if state == 'base' then table.insert(base_parts, next_item.text)
          else table.insert(ruby_parts, next_item.text) end
        elseif next_item.t == 'Space' then
          if state == 'base' then table.insert(base_parts, ' ')
          else table.insert(ruby_parts, ' ') end
        end
        j = j + 1
      end

      if found_end then
        local base_raw = table.concat(base_parts)
        local ruby_raw = table.concat(ruby_parts)
        local ruby_normalized = ruby_raw:gsub('　', ' ')
        local ruby_split = {}
        for part in ruby_normalized:gmatch('%S+') do
          table.insert(ruby_split, part)
        end
        local function xml_ruby(base_t, ruby_t)
          return '<text:ruby text:style-name="Ru1">'
            .. '<text:ruby-base>' .. esc(base_t) .. '</text:ruby-base>'
            .. '<text:ruby-text>' .. esc(ruby_t) .. '</text:ruby-text>'
            .. '</text:ruby>'
        end
        local char_count = utf8.len(base_raw)
        if #ruby_split > 1 and #ruby_split == char_count then
          local idx = 1
          for char in base_raw:gmatch('.[\128-\191]*') do
            table.insert(new_content, pandoc.RawInline('opendocument', xml_ruby(char, ruby_split[idx])))
            idx = idx + 1
          end
        else
          table.insert(new_content, pandoc.RawInline('opendocument', xml_ruby(base_raw, ruby_raw)))
        end
        i = j
      else
        table.insert(new_content, item)
      end
    else
      table.insert(new_content, item)
    end
    i = i + 1
  end
  el.content = new_content
  return el
end

return {
  Para = process_ruby,
  Plain = process_ruby
}
