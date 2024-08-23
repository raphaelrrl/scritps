### Para integrar Andrisoft Wanguard Anti-DDoS com Grafana, você pode seguir estes passos principais: 
### utilizar a API do Wanguard para coletar dados, armazená-los em um banco de dados (como MySQL), e configurar o Grafana para visualizar esses dados. 
### Vou desenvolver um exemplo de script Python que faz essa integração.

### Passo 1: Configurar o Banco de Dados

1. **Instale MySQL**:
   ```bash
   sudo apt update
   sudo apt install mysql-server
   sudo mysql_secure_installation
   ```

2. **Crie o banco de dados e a tabela**:
   ```sql
   CREATE DATABASE wanguard_data;

   USE wanguard_data;

   CREATE TABLE ddos_metrics (
       id INT AUTO_INCREMENT PRIMARY KEY,
       timestamp DATETIME,
       attack_type VARCHAR(255),
       attack_target VARCHAR(255),
       attack_size FLOAT,
       attack_duration FLOAT
   );
   ```

### Passo 2: Script Python para Extrair Dados do Wanguard

1. **Instale as bibliotecas necessárias**:
   ```bash
   pip install requests mysql-connector-python
   ```

2. **Desenvolva o script Python**:
   ```python
   import requests
   import mysql.connector
   from datetime import datetime

   # Configurações do Andrisoft Wanguard
   wanguard_api_url = 'http://<wanguard-api-url>/api/v1/ddos/attacks'
   wanguard_api_key = 'your_api_key'

   # Configurações do Banco de Dados MySQL
   db_config = {
       'user': 'your_db_user',
       'password': 'your_db_password',
       'host': 'localhost',
       'database': 'wanguard_data'
   }

   def fetch_wanguard_data():
       headers = {'Authorization': f'Bearer {wanguard_api_key}'}
       response = requests.get(wanguard_api_url, headers=headers)
       response.raise_for_status()
       return response.json()

   def store_data_in_db(data):
       conn = mysql.connector.connect(**db_config)
       cursor = conn.cursor()

       for attack in data['attacks']:
           timestamp = datetime.strptime(attack['timestamp'], '%Y-%m-%dT%H:%M:%S')
           attack_type = attack['type']
           attack_target = attack['target']
           attack_size = attack['size']
           attack_duration = attack['duration']

           query = """
           INSERT INTO ddos_metrics (timestamp, attack_type, attack_target, attack_size, attack_duration)
           VALUES (%s, %s, %s, %s, %s)
           """
           cursor.execute(query, (timestamp, attack_type, attack_target, attack_size, attack_duration))
       
       conn.commit()
       cursor.close()
       conn.close()

   def main():
       try:
           data = fetch_wanguard_data()
           store_data_in_db(data)
           print("Dados armazenados com sucesso!")
       except Exception as e:
           print(f"Erro ao processar dados: {e}")

   if __name__ == "__main__":
       main()
   ```

### Passo 3: Configurar Grafana

1. **Adicione MySQL como Fonte de Dados no Grafana**:
   - Acesse o Grafana e vá para **Configuration (⚙️)** > **Data Sources** > **Add data source**.
   - Escolha **MySQL** e configure a conexão com o banco de dados que você criou.

2. **Crie um Dashboard**:
   - Crie um novo dashboard e adicione painéis.
   - Configure as consultas SQL para exibir os dados armazenados na tabela `ddos_metrics`.

### Exemplo de Consulta SQL para Grafana

```sql
SELECT
  timestamp AS "Time",
  attack_type AS "Attack Type",
  attack_target AS "Attack Target",
  attack_size AS "Attack Size",
  attack_duration AS "Attack Duration"
FROM
  ddos_metrics
WHERE
  $__timeFilter(timestamp)
ORDER BY
  timestamp DESC
```

Isso permitirá que você visualize os dados do Andrisoft Wanguard no Grafana. Para mais detalhes, consulte a [documentação oficial do Andrisoft Wanguard](https://www.andrisoft.com/docs/wanguard/8.3/index.html).
