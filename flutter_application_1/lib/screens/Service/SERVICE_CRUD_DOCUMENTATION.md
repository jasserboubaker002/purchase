# Integration CRUD API Services

## Overview

This implementation provides a complete REST API CRUD integration for the Service entity in the Flutter application. The system is based on a layered architecture with models, network layer, controllers, and screens.

## Architecture

### 1. **Model Layer** (`lib/models/service.dart`)
- **Class**: `Service`
- **Fields**:
  - `id`: int (nullable) - Service identifier
  - `name`: String (required) - Service name
  - `description`: String (nullable) - Service description
  - `createdAt`: DateTime (nullable) - Creation timestamp
  - `updatedAt`: DateTime (nullable) - Last update timestamp

- **Methods**:
  - `fromJson()`: Deserialize JSON to Service object
  - `toJson()`: Serialize Service object to JSON
  - `copyWith()`: Create a copy with updated fields

### 2. **Network Layer** (`lib/network/service_network.dart`)
- **Class**: `ServiceNetwork`
- **Base URL**: `http://127.0.0.1:8000/`
- **Endpoint**: `/service/services/`
- **Authentication**: JWT Bearer Token

#### Methods:
- `fetchServices()`: GET all services
  - Request: `GET /service/services/`
  - Returns: `List<Service>`

- `getServiceById(int id)`: GET service by ID
  - Request: `GET /service/services/{id}/`
  - Returns: `Service`

- `createService(Service service)`: POST create service
  - Request: `POST /service/services/`
  - Body: JSON with name and description
  - Returns: `Service`

- `updateService(int id, Service service)`: PUT update service
  - Request: `PUT /service/services/{id}/`
  - Body: JSON with updated name and description
  - Returns: `Service`

- `deleteService(int id)`: DELETE service
  - Request: `DELETE /service/services/{id}/`
  - Returns: void

### 3. **Controller Layer** (`lib/controllers/service_controller.dart`)
- **Class**: `ServiceController` extends `ChangeNotifier`
- **State Management**: Provider pattern

#### Properties:
- `services`: List<Service> - Cached services list
- `isLoading`: bool - Loading state indicator
- `errorMessage`: String? - Last error message

#### Methods:
- `fetchServices()`: Load all services from API
- `getServiceById(id)`: Fetch single service details
- `createService({name, description})`: Create new service
- `updateService({id, name, description})`: Update existing service
- `deleteService(id)`: Delete a service
- `clearServices()`: Clear the services list

### 4. **UI Layer** (Screens in `lib/screens/Service/`)

#### a. **ServiceListScreen** (`service_list_screen.dart`)
- Display list of all services
- Features:
  - Refresh button to reload services
  - Floating Action Button to add new service
  - Edit button for each service card
  - Delete button with confirmation dialog
  - Error handling with retry option
  - Empty state message

#### b. **AddServiceScreen** (`add_service_screen.dart`)
- Form to create a new service
- Fields:
  - Service Name (required, TextField)
  - Description (optional, TextField)
- Features:
  - Form validation
  - Loading indicator during submission
  - Error handling with snackbar
  - Success feedback

#### c. **EditServiceScreen** (`edit_service_screen.dart`)
- Form to update an existing service
- Pre-filled with current service data
- Same fields as AddServiceScreen
- Features:
  - Form validation
  - Loading indicator during submission
  - Error handling with snackbar
  - Success feedback

## API Endpoints Configuration

Added to `lib/network/api.dart`:
```dart
static const String fetchServices = "service/services/";
static const String createService = "service/services/";
static const String editService = "service/services/";
static const String deleteService = "service/services/";
```

## Integration Steps

### 1. **Provider Setup** (`lib/main.dart`)
```dart
ChangeNotifierProvider(create: (_) => ServiceController()),
```

Added in:
- `main()` - MultiProvider
- `MyApp.build()` - MultiProvider
- Added import: `import 'package:flutter_application_1/controllers/service_controller.dart';`

### 2. **Navigation Setup**
- Updated `main.dart` to handle 'Service' case in `_getPage()` switch
- Added import for ServiceListScreen

### 3. **Sidebar Menu** (`lib/widgets/sidebar.dart`)
- Added 'Service' menu item for Admin role (roleId == 1)
- Icon: `Icons.miscellaneous_services`
- Added localization key mapping

### 4. **Localization** (`lib/l10n/*.arb`)
- Added "service": "Service" to all language files:
  - `app_en.arb`
  - `app_fr.arb`
  - `app_ar.arb`

## Usage Example

### Fetching Services
```dart
final controller = context.read<ServiceController>();
await controller.fetchServices();
```

### Creating a Service
```dart
await controller.createService(
  name: 'Consultation',
  description: 'Professional consultation services',
);
```

### Updating a Service
```dart
await controller.updateService(
  id: 1,
  name: 'Updated Consultation',
  description: 'Updated description',
);
```

### Deleting a Service
```dart
await controller.deleteService(1);
```

## Error Handling

- All network calls include try-catch blocks
- Errors propagate to UI through:
  - `errorMessage` property on controller
  - SnackBar notifications on screens
  - Retry buttons on error states
- Console logging with `print()` for debugging

## Authentication

- All API requests include JWT Bearer token
- Token obtained from `APIS.token` static property
- Added to headers: `Authorization: Bearer <token>`

## State Management

- Uses Provider package for state management
- `Consumer<ServiceController>` for reactive UI updates
- Automatic UI rebuild on service list changes
- Loading states managed with `isLoading` boolean

## Features

✅ Create Service - Add new service with name and description
✅ Read Service - Fetch single or all services
✅ Update Service - Modify existing service details
✅ Delete Service - Remove service with confirmation
✅ Error Handling - Display errors to user
✅ Loading States - Show progress indicators
✅ Multi-language Support - English, French, Arabic
✅ Admin Access Control - Service management for Admin role
✅ Form Validation - Required field validation
✅ JWT Authentication - Secure API calls

## Future Enhancement Options

1. **Search & Filter**: Add search by name or description
2. **Pagination**: Implement pagination for large service lists
3. **Service Categories**: Group services by category
4. **Service Pricing**: Add pricing information to services
5. **Service Assignment**: Link services to users/departments
6. **Bulk Operations**: Add bulk create/update/delete
7. **Export**: Export services to CSV or PDF
8. **Advanced Filtering**: Filter by created date, status, etc.

## Testing

To test the Service CRUD functionality:

1. Navigate to the Service menu item (visible to Admin users)
2. View list of services
3. Click "Add Service" to create a new service
4. Fill in the form and submit
5. Edit a service by clicking the edit icon
6. Delete a service with the delete confirmation
7. Use the refresh button to reload services

## Files Created/Modified

### Created:
- `lib/controllers/service_controller.dart`
- `lib/screens/Service/service_list_screen.dart`
- `lib/screens/Service/add_service_screen.dart`
- `lib/screens/Service/edit_service_screen.dart`

### Modified:
- `lib/main.dart` - Added provider and route
- `lib/widgets/sidebar.dart` - Added menu item
- `lib/l10n/app_en.arb` - Added translation
- `lib/l10n/app_fr.arb` - Added translation
- `lib/l10n/app_ar.arb` - Added translation

### Already Present (No Changes):
- `lib/models/service.dart`
- `lib/network/service_network.dart`
- `lib/network/api.dart`

## Notes

- The implementation follows the existing patterns in the codebase (Supplier, Department management)
- All UI components are responsive and work on both mobile and web
- Error messages provide clear feedback to users
- The system gracefully handles network failures and timeouts
- JWT token is managed centrally and included in all requests
