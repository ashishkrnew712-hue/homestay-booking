const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.onBookingWritten = onDocumentWritten("bookings/{bookingId}", async (event) => {
  const beforeData = event.data.before.data();
  const afterData = event.data.after.data();

  let title = "";
  let body = "";

  if (!beforeData && afterData) {
    // Created
    title = `New Booking: ${afterData.roomName}`;
    body = `${afterData.guestName} booked for ${afterData.numberOfGuests} guest(s).`;
  } else if (beforeData && !afterData) {
    // Deleted
    title = `Booking Cancelled: ${beforeData.roomName}`;
    body = `${beforeData.guestName}'s booking was removed.`;
  } else if (beforeData && afterData) {
    // Updated
    // Check if status changed
    if (beforeData.isActive === true && afterData.isActive === false) {
      title = `Booking Cancelled: ${afterData.roomName}`;
      body = `${afterData.guestName} cancelled their booking.`;
    } else {
      title = `Booking Updated: ${afterData.roomName}`;
      body = `Updates made to ${afterData.guestName}'s booking.`;
    }
  }

  if (!title) return null;

  const payload = {
    notification: {
      title: title,
      body: body,
    },
    topic: "booking_updates",
  };

  try {
    console.log("Sending notification to topic:", payload);
    await admin.messaging().send(payload);
    console.log("Notification sent successfully");
  } catch (error) {
    console.error("Error sending notification:", error);
  }
  
  return null;
});
