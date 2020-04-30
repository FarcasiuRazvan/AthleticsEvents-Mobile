module.exports = (app) => {
    const events = require('../controllers/event.controller.js');

    // Create a new Event
    app.post('/events', events.create);

    // Retrieve all Events
    app.get('/events', events.findAll);

    // Retrieve a single Event with eventId
    app.get('/events/:eventId', events.findOne);

    // Update a Event with eventId
    app.put('/events/:eventId', events.update);

    // Delete a Event with eventId
    app.delete('/events/:eventId', events.delete);
}