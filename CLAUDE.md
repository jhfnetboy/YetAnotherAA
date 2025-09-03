# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

YetAnotherAA is a comprehensive BLS Aggregate Signature + ERC-4337 Account Abstraction System. It integrates BLS12-381 aggregate signatures with ERC-4337 account abstraction, featuring dynamic gas calculation and multi-node signature verification.

## Architecture

This is a monorepo with workspaces containing four main components:

### Core Components

1. **validator/** - Solidity contracts (Foundry project)
   - `AAStarValidator.sol` - BLS signature validator with EIP-2537 integration
   - `AAStarAccountV6.sol` - ERC-4337 account implementation  
   - `AAStarAccountFactoryV6.sol` - Account factory contract

2. **signer/** - BLS signing service (NestJS + ES modules)
   - Independent node identity with unique BLS key pairs
   - RESTful API for signature operations
   - Gossip network for node discovery
   - WebSocket support for real-time communication

3. **aastar/** - Backend API (NestJS + CommonJS)
   - User authentication with JWT
   - ERC-4337 account management
   - Transfer operations with UserOperation handling
   - JSON file storage (ready for MongoDB migration)

4. **aastar-frontend/** - Frontend application (Next.js 15)
   - Modern React with TypeScript
   - Tailwind CSS for styling
   - WebAuthn/passkey integration
   - ERC-4337 user interface

## Development Commands

### Root Level (All Workspaces)
```bash
# Format all code
npm run format

# Check formatting
npm run format:check

# Lint all workspaces
npm run lint

# Fix linting issues
npm run lint:fix

# Build all workspaces
npm run build

# Run tests across workspaces
npm run test

# CI pipeline (format check + lint + build + test)
npm run ci
```

### Validator (Solidity)
```bash
cd validator

# Build contracts
forge build

# Run tests
forge test

# Run tests with gas reporting
forge test --gas-report

# Deploy to Sepolia (requires env vars)
forge script script/DeployValidator.s.sol --rpc-url $RPC_URL --broadcast

# Register BLS nodes
forge script script/RegisterKeys.s.sol --rpc-url $RPC_URL --broadcast
```

### Signer Service
```bash
cd signer

# Development mode
npm run start:dev

# Production mode
npm run start:prod

# Build TypeScript
npm run build

# Run single test
npm run test

# Type checking
npm run type-check
```

### Backend API
```bash
cd aastar

# Development with hot reload
npm run start:dev

# Production mode  
npm run start:prod

# Run tests with coverage
npm run test:ci

# Type checking
npm run type-check
```

### Frontend
```bash
cd aastar-frontend

# Development server with turbo
npm run dev

# Production build
npm run build

# Start production server
npm run start

# Type checking
npm run type-check
```

## Key Technical Details

### BLS Signature System
- Uses BLS12-381 curve with EIP-2537 precompiles
- 705-byte signature format: `[nodeIdsLength(32)][nodeIds...][blsSignature(256)][messagePoint(256)][aaSignature(65)]`
- Dynamic gas calculation based on node count with 25% safety margin
- Automatic node selection from gossip network

### ERC-4337 Integration  
- Compatible with EntryPoint v0.6: `0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789`
- Dual verification: ECDSA for userOpHash + BLS for messagePoint
- Gas optimization with precise estimation algorithms
- Support for paymaster integration

### Service Architecture
- **Signer**: ES modules, WebSocket gossip, node state persistence
- **Backend**: CommonJS, JWT auth, JSON storage, Swagger docs
- **Frontend**: Next.js 15, React 19, Tailwind CSS, WebAuthn

## Development Setup

### Environment Configuration
Required environment variables (create `.env` files in respective directories):

```env
# Blockchain Configuration
ETH_RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY
ETH_PRIVATE_KEY=your_private_key_here
BUNDLER_RPC_URL=https://api.pimlico.io/v2/11155111/rpc?apikey=YOUR_KEY

# Contract Addresses (deploy your own for production)
VALIDATOR_CONTRACT_ADDRESS=0x...
AASTAR_ACCOUNT_FACTORY_ADDRESS=0x...
ENTRY_POINT_ADDRESS=0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789

# Service Configuration
JWT_SECRET=your-secret-key
PORT=3000 # or 3001 for signer, 8080 for frontend
```

### Port Allocation
- Frontend: 8080
- Backend API: 3000  
- Signer Service: 3001-3003 (multi-node support)

### Development Workflow
1. Start signer service(s) first for BLS operations
2. Start backend API for user management
3. Start frontend for user interface
4. Use demo tools in `signer/demo/` for testing

## Testing

### Contract Testing
```bash
cd validator
forge test -v  # Verbose output
forge coverage  # Coverage report
```

### Service Testing  
```bash
# Backend tests with coverage
cd aastar && npm run test:ci

# Signer service tests  
cd signer && npm run test

# Frontend type checking
cd aastar-frontend && npm run type-check
```

## Security Considerations

- All node state files (`node_*.json`) contain private keys and are gitignored
- Use development keys only for testing
- Deploy your own contracts for production use
- Never commit private keys or sensitive configuration
- Template configurations provided in `.example` files

## Data Persistence

Currently uses JSON file storage in `/data` directories:
- `users.json` - User accounts with bcrypt passwords
- `accounts.json` - ERC-4337 account mappings
- `transfers.json` - Transaction history
- `bls-config.json` - BLS node configurations

Ready for MongoDB/PostgreSQL migration when scaling.