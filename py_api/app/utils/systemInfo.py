from flask_restful import Resource
import platform
import cpuinfo
import psutil

class SystemInfo(Resource):
    def get(self):

        def bytes_to_GB(bytes):
            gb = bytes/(1024*1024*1024)
            gb = round(gb, 2)
            val = str(gb)
            return val + ' GB'

        def systemData():
            return { 'Architecture':platform.architecture()[0],
                    'Machine': platform.machine(),
                    'OSRelease': platform.release(),
                    'SystemName': platform.system(),
                    'OSVersion' :platform.version(),
                    'Node': platform.node(),
                    'Platform':platform.platform(),
                    'Processor':platform.processor()
                    }

        def cpuData():
            return { 'Name' : cpuinfo.get_cpu_info()['brand_raw']}

        def memoryData():
            virtual_memory = psutil.virtual_memory()
            return {
                'Total': bytes_to_GB(virtual_memory.total),
                'Available': bytes_to_GB(virtual_memory.available),
                'Used': bytes_to_GB(virtual_memory.used)
            }
        
        def diskData():
            disk_info = []
            disk_partitions = psutil.disk_partitions()
            for partition in disk_partitions:
                disk_usage = psutil.disk_usage(partition.mountpoint)
                disk_info.append({
                    'Device': partition.device,
                    'TotalSpace': bytes_to_GB(disk_usage.total),
                    'FreeSpace' : bytes_to_GB(disk_usage.free),
                    'UsedSpace' : bytes_to_GB(disk_usage.used)
                })
            return disk_info

        def networkData():
            network_info = []
            if_addrs = psutil.net_if_addrs()
            for interface_name, interface_addresses in if_addrs.items():
                for address in interface_addresses:
                    if str(address.family) == 'AddressFamily.AF_INET':
                        network_info.append({
                            'Interface' : interface_name,
                            "IpAddress" : address.address,
                            "Netmask" : address.netmask,
                            "BroadcastIP": address.broadcast
                        })
                    elif str(address.family) == 'AddressFamily.AF_PACKET':
                        network_info.append({
                            'Interface' : interface_name,
                            "MACAddress" : address.address,
                            "Netmask" : address.netmask,
                            "Broadcast MAC": address.broadcast
                        })
            return network_info



        return { 
            'HostInfo': {
                'System':systemData(),
                'Cpu': cpuData(),
                'Ram': memoryData(),
                'Disk' : diskData(),
                'Network' : networkData()
                }
            }

