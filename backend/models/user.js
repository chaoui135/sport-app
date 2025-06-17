const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const UserSchema = new mongoose.Schema({
  userId: { type: String, unique: true, required: true },
  userName: { type: String, required: true },
  password: { type: String, required: true },
  fullName: { type: String, required: true },
});

UserSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();

  try {
    this.password = await bcrypt.hash(this.password, 10);
    next();
  } catch (error) {
    next(error);
  }
});

const User = mongoose.model('User', UserSchema);
module.exports = User;