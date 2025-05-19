const sql = require('mssql');

const dbConfig = {
    server: 'BOXYCOMET15', // El nombre de tu servidor
    database: 'CineDB', // Nombre de tu base de datos
    options: {
        trustServerCertificate: true,
        encrypt: false
    },
    authentication: {
        type: 'default', // Autenticación SQL
        options: {
            userName: 'sa', // El nombre de usuario SQL
            password: 'a2223330185' // La contraseña del usuario SQL
        }
    }
};

let pool = null;

async function connectDB() {
  if (!pool) {
    try {
      pool = await sql.connect(dbConfig);
      console.log("✅ Conexión establecida a SQL Server");
    } catch (err) {
      console.error("❌ Error al conectar a SQL Server:", err);
      throw err;
    }
  }
  return pool;
}

module.exports = { connectDB, sql, dbConfig };