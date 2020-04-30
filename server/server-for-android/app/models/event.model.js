const mongoose = require('mongoose');

const EventSchema = mongoose.Schema({
    title: String,
	photo_url: String,
    description: String
}, {
    timestamps: true
	//If set timestamps, mongoose assigns createdAt and updatedAt fields to your schema, the type assigned is Date.
});

module.exports = mongoose.model('Event', EventSchema);