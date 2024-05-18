import csv
from influxdb import InfluxDBClient

# Configuração do InfluxDB
influxdb_host = 'localhost'
influxdb_port = 8086
influxdb_user = 'username'
influxdb_password = 'password'
influxdb_database = 'nfdump'

# Inicializando o cliente do InfluxDB
client = InfluxDBClient(host=influxdb_host, port=influxdb_port, username=influxdb_user, password=influxdb_password)

# Verificando se o banco de dados existe, caso contrário, criando-o
databases = client.get_list_database()
if {'name': influxdb_database} not in databases:
    client.create_database(influxdb_database)
client.switch_database(influxdb_database)

# Função para converter os dados do CSV para o formato do InfluxDB
def convert_to_influxdb_format(csv_file):
    points = []
    with open(csv_file, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            point = {
                "measurement": "nfdump_data",
                "tags": {
                    "src_ip": row['src_ip'],
                    "dst_ip": row['dst_ip']
                },
                "time": row['timestamp'],
                "fields": {
                    "bytes": int(row['bytes']),
                    "packets": int(row['packets']),
                    "src_port": int(row['src_port']),
                    "dst_port": int(row['dst_port']),
                    "protocol": row['protocol']
                }
            }
            points.append(point)
    return points

# Caminho para o arquivo CSV gerado pelo NFdump
csv_file_path = 'nfdump_data.csv'

# Convertendo e enviando os dados para o InfluxDB
data_points = convert_to_influxdb_format(csv_file_path)
client.write_points(data_points)

print("Dados enviados para o InfluxDB com sucesso!")
