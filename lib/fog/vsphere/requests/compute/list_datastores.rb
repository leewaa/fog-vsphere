module Fog
  module Compute
    class Vsphere
      class Real
        def list_datastores(filters = {})
          datacenter_name = filters[:datacenter]
          cluster_name = filters.fetch(:cluster, nil)
          # default to show all datastores
          only_active = filters[:accessible] || false
          raw_datastores(datacenter_name, cluster_name).map do |datastore|
            next if only_active && !datastore.summary.accessible
            datastore_attributes(datastore, datacenter_name)
          end.compact
        end

        def raw_datastores(datacenter_name, cluster = nil)
          if cluster.nil?
            find_raw_datacenter(datacenter_name).datastore
          else
            get_raw_cluster(cluster, datacenter_name).datastore
          end
        end

        protected

        def datastore_attributes(datastore, datacenter)
          {
            id: managed_obj_id(datastore),
            name: datastore.name,
            accessible: datastore.summary.accessible,
            type: datastore.summary.type,
            freespace: datastore.summary.freeSpace,
            capacity: datastore.summary.capacity,
            uncommitted: datastore.summary.uncommitted,
            datacenter: datacenter
          }
        end
      end
      class Mock
        def list_datastores(filters)
          datacenter_name = filters[:datacenter]
          cluster_name = filters.fetch(:cluster, nil)
          if cluster_name.nil?
            data[:datastores].values.select { |d| d['datacenter'] == datacenter_name } ||
              raise(Fog::Compute::Vsphere::NotFound)
          else
            data[:datastores].values.select { |d| d['datacenter'] == datacenter_name && d['cluster'].include?(cluster_name) } ||
              raise(Fog::Compute::Vsphere::NotFound)
          end
        end
      end
    end
  end
end
