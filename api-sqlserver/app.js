const express = require('express');
const cors = require('cors');
const app = express();
const adminRoutes = require('./rutas/AdminConexion');
const { connectDB } = require('./db'); // 👈 Importamos correctamente la función

app.use(cors());
app.use(express.json());
app.use('/api/admin', adminRoutes);

const PORT = 3000;

app.listen(PORT, async () => {
    await connectDB(); // 👈 Ahora sí funciona sin error
    console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
});
