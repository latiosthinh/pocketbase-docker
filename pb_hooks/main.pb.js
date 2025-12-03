/// <reference path="../pb_data/types.d.ts" />

onAfterBootstrap((e) => {
  const adminEmail = process.env.ADMIN_EMAIL || "admin@example.com";
  const adminPassword = process.env.ADMIN_PASSWORD || "changeme123";

  try {
    // Try to find existing admin
    const admin = $app.dao().findAdminByEmail(adminEmail);
    console.log(`Admin user ${adminEmail} already exists`);
  } catch (err) {
    // Admin doesn't exist, create one
    const admin = new Admin();
    admin.email = adminEmail;
    admin.setPassword(adminPassword);
    
    $app.dao().saveAdmin(admin);
    console.log(`Created admin user: ${adminEmail}`);
  }
});
