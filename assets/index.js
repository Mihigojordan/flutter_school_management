const express = require('express');
const fs = require('fs');
const path = require('path');
const cors = require('cors');
const helmet = require('helmet');
const xssClean = require('xss-clean');
const cookieParser = require('cookie-parser');
const sequelize = require('./config/config');

// Load environment variables only in development
if (process.env.NODE_ENV !== 'production') {
    try {
        require('dotenv').config();
        console.log('Environment variables loaded from .env file');
    } catch (error) {
        console.warn('Could not load .env file. Using system environment variables.');
    }
} else {
    console.log('Production environment: Skipping .env file loading');
}

// Router declarations
const AdminAuth = require('./router/Admin/Auth');
const Module = require('./router/Admin/module');
const Catalogy = require('./router/Admin/Catalogy');
const AdminCompany = require('./router/Admin/Company');
const Permission = require('./router/Admin/permission');

const CompanyAuth = require('./router/insurance_company/Auth');
const CompanyAccessor = require('./router/insurance_company/Loss_accessor');
const CompanyUser = require('./router/insurance_company/User');
const Company_Quotation = require('./router/insurance_company/Quotation');
const EmployeeRouter = require('./router/insurance_company/Employee');

const AccessorAuth = require('./router/LossAccessor/Auth');
const Accessor_Quotation = require('./router/LossAccessor/Quotation');
const CountRoutes = require("./router/Count/count");
const LossAccessorCountRoutes = require("./router/Count/LossACCessorCount");
const CompanyCountRoutes = require("./router/Count/CompanyCount");

const app = express();

// Define allowed origins for CORS
const allowedOrigins = [
    "https://insurance.gvibyequ.a2hosted.com", // Production frontend
    "http://localhost:5173" // Local development
];

// CORS Middleware
app.use(cors({
    origin: (origin, callback) => {
        if (!origin || allowedOrigins.includes(origin)) {
            callback(null, true);
        } else {
            callback(new Error('Not allowed by CORS'));
        }
    },
    credentials: true // Allow cookies and other credentials
}));

// Preflight Request Handler
app.options('*', (req, res) => {
    const origin = req.headers.origin;
    if (allowedOrigins.includes(origin)) {
        res.header('Access-Control-Allow-Origin', origin);
        res.header('Access-Control-Allow-Methods', 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS');
        res.header('Access-Control-Allow-Headers', 'Content-Type,Authorization');
        res.header('Access-Control-Allow-Credentials', 'true');
        res.sendStatus(200);
    } else {
        res.sendStatus(403); // Forbidden
    }
});

// Serve static files from the /uploads directory
app.use('/uploads', (req, res, next) => {
    const origin = req.headers.origin;
    if (allowedOrigins.includes(origin)) {
        res.setHeader('Access-Control-Allow-Origin', origin);
        res.setHeader('Access-Control-Allow-Credentials', 'true');
        res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    }
    next();
}, express.static(path.join(__dirname, 'uploads')));

// Security Middleware
app.use(helmet());
app.use(xssClean());
app.use(cookieParser());

app.use(helmet.contentSecurityPolicy({
    directives: {
        defaultSrc: ["'self'"],
        scriptSrc: ["'self'", "'unsafe-inline'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        imgSrc: ["'self'", "http://localhost:5173", "https://insurance.gvibyequ.a2hosted.com", "data:"],
        objectSrc: ["'none'"],
        upgradeInsecureRequests: [],
    },
}));

// Middleware for handling JSON and URL-encoded data
app.use(express.json({ limit: '100mb' })); // For JSON requests
app.use(express.urlencoded({ extended: true, limit: '100mb' })); // For URL-encoded requests

// Router usage (register routes)
app.use('/api/admin/auth', AdminAuth);
app.use('/api/admin/module', Module);
app.use('/api/catalogy', Catalogy);
app.use('/api/admin/company', AdminCompany);
app.use('/api/admin/permission', Permission);

app.use('/api/company/auth', CompanyAuth);
app.use('/api/company/loss-accessor', CompanyAccessor);
app.use('/api/company/user', CompanyUser);
app.use('/api/company/quotation', Company_Quotation);
app.use('/api/company/employee', EmployeeRouter);

app.use('/api/LossAccessor/auth', AccessorAuth);
app.use('/api/LossAccessor/quotation', Accessor_Quotation);
app.use("/api", CountRoutes);
app.use("/api/lossAccessor", LossAccessorCountRoutes);
app.use("/api/company", CompanyCountRoutes);

// Sync the database with Sequelize
sequelize.sync({ alter: true })
    .then(() => console.log('Database synced successfully'))
    .catch((err) => {
        console.error('Error syncing database:', err);
    });

// Basic route for API testing
app.get('/api', (req, res) => {
    res.json({ message: 'Hello, welcome to my backend API!' });
});

// Global Error Handling Middleware
app.use((err, req, res, next) => {
    console.error('Error:', err.stack);
    res.status(500).send('Internal server error occurred');
});

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});

