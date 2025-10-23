# Backend OpenAI Integration Setup

## 🔴 CRITICAL: You MUST Add This to Your Backend

Your AI Chatbot will NOT work until you add this backend endpoint!

---

## Step 1: Install OpenAI Package

In your backend folder:

```bash
npm install openai
```

---

## Step 2: Add OpenAI Key to .env

In your backend `.env` file, add:

```env
OPENAI_API_KEY=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
```

---

## Step 3: Create AI Controller

Create file: `backend/controllers/aiController.js`

```javascript
const OpenAI = require('openai');

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// System prompt that defines the AI mentor's personality and knowledge
const SYSTEM_PROMPT = `You are an expert AI Career Mentor for Hakbang, a Filipino IT career guidance platform. Your role is to help students:

1. **Choose IT Career Paths**: Guide students in selecting careers like Web Developer, Data Scientist, Mobile Developer, Cybersecurity Specialist, etc.

2. **Learning Recommendations**: Suggest resources, courses, and learning paths based on their interests and goals.

3. **Career Advice**: Provide insights about:
   - Salary ranges in the Philippines (₱20,000-₱150,000+ depending on experience)
   - Required skills and technologies
   - Career growth opportunities
   - Industry trends

4. **Motivation & Support**: Encourage students who are struggling or feeling overwhelmed. Remind them that every expert was once a beginner.

5. **Study Tips**: Share effective learning strategies like:
   - Breaking problems into smaller steps
   - Consistent practice (30min-1hr daily)
   - Building projects to apply knowledge
   - Joining communities for support

**Communication Style:**
- Friendly, encouraging, and professional
- Use simple English (Filipinos speak English but prefer clear explanations)
- Include Filipino context (salary in Pesos, local job market)
- Be specific with actionable advice
- Use emojis sparingly for warmth (🚀💪🌟)

**Available Careers in Hakbang:**
- Web Developer
- Data Scientist
- Mobile App Developer
- Cybersecurity Specialist
- Cloud Engineer
- DevOps Engineer
- UI/UX Designer
- Game Developer

**Key Points:**
- Emphasize that IT careers don't always require a degree
- Highlight the importance of portfolios and practical skills
- Mention Hakbang's features: learning modules, quizzes, community forum
- Encourage taking the career assessment quiz for personalized recommendations

Keep responses concise (2-3 paragraphs max) unless the user asks for detailed explanations.`;

/**
 * Send message to AI chatbot
 * POST /api/ai/chat
 */
exports.sendMessage = async (req, res) => {
  try {
    const { message, conversationHistory } = req.body;

    if (!message || message.trim().length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Message is required',
      });
    }

    // Build messages array for OpenAI
    const messages = [
      { role: 'system', content: SYSTEM_PROMPT },
    ];

    // Add conversation history if provided
    if (conversationHistory && Array.isArray(conversationHistory)) {
      conversationHistory.forEach((msg) => {
        if (msg.role && msg.content) {
          messages.push({
            role: msg.role === 'user' ? 'user' : 'assistant',
            content: msg.content,
          });
        }
      });
    }

    // Add current user message
    messages.push({
      role: 'user',
      content: message,
    });

    console.log('📤 Sending to OpenAI with', messages.length, 'messages');

    // Call OpenAI API
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini', // or 'gpt-4' for better responses but higher cost
      messages: messages,
      max_tokens: 500, // Limit response length
      temperature: 0.7, // Balance between creative and focused
    });

    const aiReply = completion.choices[0].message.content;

    console.log('✅ OpenAI response received');

    res.status(200).json({
      success: true,
      reply: aiReply,
      usage: {
        promptTokens: completion.usage.prompt_tokens,
        completionTokens: completion.usage.completion_tokens,
        totalTokens: completion.usage.total_tokens,
      },
    });
  } catch (error) {
    console.error('❌ OpenAI API Error:', error);

    if (error.status === 401) {
      return res.status(500).json({
        success: false,
        error: 'Invalid OpenAI API key. Please check backend configuration.',
      });
    }

    if (error.status === 429) {
      return res.status(429).json({
        success: false,
        error: 'OpenAI rate limit exceeded. Please try again in a moment.',
      });
    }

    res.status(500).json({
      success: false,
      error: 'Failed to get AI response. Please try again.',
      details: error.message,
    });
  }
};

/**
 * Get career recommendations based on quiz responses
 * POST /api/ai/recommendations
 */
exports.getRecommendations = async (req, res) => {
  try {
    const { quizResponses } = req.body;

    if (!quizResponses || !Array.isArray(quizResponses)) {
      return res.status(400).json({
        success: false,
        error: 'Quiz responses are required',
      });
    }

    // Format quiz responses for AI
    const quizSummary = quizResponses
      .map((q, i) => `Q${i + 1}: ${q.question}\nA: ${q.answer}`)
      .join('\n\n');

    const prompt = `Based on this career assessment quiz, recommend the top 3 most suitable IT careers from this list: Web Developer, Data Scientist, Mobile App Developer, Cybersecurity Specialist, Cloud Engineer, DevOps Engineer, UI/UX Designer, Game Developer.

Quiz Responses:
${quizSummary}

Respond in JSON format:
{
  "recommendations": [
    {
      "title": "Career Name",
      "matchPercentage": 85,
      "reasons": ["Reason 1", "Reason 2", "Reason 3"]
    }
  ]
}`;

    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        { role: 'system', content: 'You are an IT career advisor. Respond only with valid JSON.' },
        { role: 'user', content: prompt },
      ],
      max_tokens: 800,
      temperature: 0.5,
    });

    const aiResponse = completion.choices[0].message.content;
    
    // Parse JSON response
    const jsonMatch = aiResponse.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      throw new Error('Invalid JSON response from AI');
    }
    
    const parsed = JSON.parse(jsonMatch[0]);

    // Fetch actual career data from database
    const Career = require('../models/Career'); // Adjust path to your Career model
    const recommendedCareers = await Career.find({
      title: { $in: parsed.recommendations.map(r => r.title) }
    });

    // Return careers with match data
    const result = recommendedCareers.map(career => {
      const matchData = parsed.recommendations.find(r => r.title === career.title);
      return {
        _id: career._id,
        title: career.title,
        description: career.description,
        salaryRange: career.salaryRange,
        matchPercentage: matchData?.matchPercentage || 75,
        reasons: matchData?.reasons || [],
      };
    });

    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    console.error('❌ AI Recommendations Error:', error);

    res.status(500).json({
      success: false,
      error: 'Failed to generate recommendations',
      details: error.message,
    });
  }
};
```

---

## Step 4: Create AI Routes

Create file: `backend/routes/aiRoutes.js`

```javascript
const express = require('express');
const router = express.Router();
const { sendMessage, getRecommendations } = require('../controllers/aiController');
const { protect } = require('../middleware/auth'); // Your auth middleware

// POST /api/ai/chat - Send message to AI chatbot
router.post('/chat', protect, sendMessage);

// POST /api/ai/recommendations - Get career recommendations
router.post('/recommendations', protect, getRecommendations);

module.exports = router;
```

---

## Step 5: Register Routes in Main App

In your `backend/server.js` or `backend/app.js`, add:

```javascript
const aiRoutes = require('./routes/aiRoutes');

// ... other middleware

app.use('/api/ai', aiRoutes);
```

---

## Step 6: Test the Endpoints

### Test AI Chat
```bash
curl -X POST http://localhost:3000/api/ai/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "message": "What is a web developer?",
    "conversationHistory": []
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "reply": "A web developer builds and maintains websites and web applications..."
}
```

### Test AI Recommendations
```bash
curl -X POST http://localhost:3000/api/ai/recommendations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "quizResponses": [
      {"question": "What interests you?", "answer": "Building websites"},
      {"question": "Preferred work style?", "answer": "Creative"}
    ]
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "title": "Web Developer",
      "description": "...",
      "salaryRange": "₱30,000 - ₱80,000",
      "matchPercentage": 90,
      "reasons": ["Creative outlet", "High demand", "Remote work"]
    }
  ]
}
```

---

## Step 7: Update Community Posts Endpoint

In your `backend/controllers/communityController.js`, add the create post function:

```javascript
/**
 * Create a new community post
 * POST /api/community/posts
 */
exports.createPost = async (req, res) => {
  try {
    const { title, content, category } = req.body;

    if (!title || !content) {
      return res.status(400).json({
        success: false,
        error: 'Title and content are required',
      });
    }

    const Post = require('../models/Post'); // Your Post model

    const newPost = await Post.create({
      title,
      content,
      category: category || 'general',
      authorId: req.user.id,
      authorName: req.user.username || req.user.name,
      authorRole: req.user.role,
    });

    res.status(201).json({
      success: true,
      data: newPost,
    });
  } catch (error) {
    console.error('Create post error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create post',
    });
  }
};
```

And in `backend/routes/communityRoutes.js`:

```javascript
router.post('/posts', protect, createPost);
```

---

## Step 8: Fix Module Filtering

In your `backend/controllers/learningController.js`, ensure this exists:

```javascript
/**
 * Get all modules, optionally filtered by career
 * GET /api/learning/modules?careerId=CAREER_ID
 */
exports.getModules = async (req, res) => {
  try {
    const { careerId } = req.query;

    const filter = {};
    if (careerId) {
      filter.careerId = careerId;
    }

    const Module = require('../models/Module');
    const modules = await Module.find(filter).sort({ order: 1 });

    res.status(200).json({
      success: true,
      data: modules,
    });
  } catch (error) {
    console.error('Get modules error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch modules',
    });
  }
};
```

---

## 🚀 After Setup

1. Restart your backend server
2. Test all endpoints with the curl commands above
3. Run your Flutter app
4. Test the AI Chatbot - it should now give MUCH better responses!
5. Test the career quiz - it should show actual career recommendations
6. Test community posts - you should be able to create posts

---

## 📊 Cost Estimation

**OpenAI GPT-4o-mini pricing:**
- $0.150 per 1M input tokens
- $0.600 per 1M output tokens

**Estimated cost per conversation:**
- ~500 tokens per chat message = $0.0004 per message
- ~1000 messages = $0.40

**Very affordable for development and testing!**

---

## ⚠️ Important Notes

1. **API Key Security**: Never commit your `.env` file to Git!
2. **Rate Limiting**: OpenAI has rate limits. For production, add caching.
3. **Error Handling**: The code includes proper error handling for rate limits and auth errors.
4. **Model Choice**: 
   - `gpt-4o-mini`: Faster, cheaper, good quality
   - `gpt-4`: Best quality, slower, more expensive

---

## 🎯 What This Fixes

✅ AI Chatbot will give intelligent, context-aware responses
✅ Career quiz will provide personalized recommendations
✅ Conversations will have memory (via conversationHistory)
✅ Responses will be tailored to Filipino IT industry
✅ Cost-effective with gpt-4o-mini model

---

**After you add this to your backend, your AI features will be FULLY FUNCTIONAL!** 🚀
