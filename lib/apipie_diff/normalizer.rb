module ApipieDiff
  class Normalizer
    def normalize(docs)
      ensure_key!(docs, 'docs')
      ensure_key!(docs['docs'], 'resources')

      normalized = {}
      resources = docs['docs']['resources']

      resources.keys.sort.each do |resource_name|
        normalized[resource_name] = normalize_resource(resources[resource_name])
      end
      normalized
    end

    def normalize_resource(resource)
      ensure_key!(resource, 'methods')

      resource['methods'] = resource['methods'].inject({}) do |h, m|
        h.update(m['name'] => normalize_method(m))
      end
      resource
    end

    def normalize_method(m)
      ensure_key!(m, 'params')
      ensure_key!(m, 'apis')

      params = m['params'].map do |p|
        h = slice_hash(p, ['name', 'description', 'validator', 'expected_type', 'validations'])
        h['description'] = h['description'].strip
        h
      end
      apis = m['apis'].map do |a|
        h = {
          'route' => a['http_method'] + ' ' + a['api_url'],
          'short_description' => a['short_description'],
        }
        h['deprecated'] = a['deprecated'] unless a['deprecated'].nil?
        h
      end
      {
        'apis' => apis,
        'params' => params
      }
    end

    protected

    def ensure_key!(docs, key_name)
      raise RuntimeError, "Key '#{key_name}' is missing" if docs[key_name].nil?
    end

    def slice_hash(h, fields)
      fields.inject({}) do |slice, f|
        slice.merge({f => h[f]})
      end
    end
  end
end
