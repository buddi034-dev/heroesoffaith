// Node.js script to convert AI images to base64 and update Cloudflare Worker
const fs = require('fs');
const path = require('path');

// Image file mappings
const IMAGE_FILES = {
  'alexander-duff-ai.jpg': 'assets/images/Alexander duff new.jpg',
  'amy-carmichael-ai.jpg': 'assets/images/Amy Carmicheal new.jpg',
  'ida-scudder-ai.jpg': 'assets/images/ida scudder new.jpg',
  'james-hudson-taylor-ai.jpg': 'assets/images/james hudson taylor new.jpg',
  'pandita-ramabai-ai.jpg': 'assets/images/pandita ramabai new.jpg',
  'william-carey-ai.jpg': 'assets/images/william carey new.jpg',
};

function convertImagesToBase64() {
  const base64Images = {};
  
  console.log('🔄 Converting AI images to base64...');
  
  for (const [outputName, inputPath] of Object.entries(IMAGE_FILES)) {
    try {
      if (!fs.existsSync(inputPath)) {
        console.log(`⚠️  Warning: ${inputPath} not found, skipping ${outputName}`);
        continue;
      }
      
      // Read image file
      const imageBuffer = fs.readFileSync(inputPath);
      
      // Convert to base64
      const base64String = imageBuffer.toString('base64');
      base64Images[outputName] = base64String;
      
      const sizeKB = Math.round(imageBuffer.length / 1024);
      console.log(`✅ ${outputName}: ${sizeKB} KB`);
      
    } catch (error) {
      console.error(`❌ Error processing ${outputName}:`, error.message);
    }
  }
  
  return base64Images;
}

function updateWorkerScript(base64Images) {
  const workerPath = 'src/worker.js';
  
  try {
    // Read current worker script
    let workerContent = fs.readFileSync(workerPath, 'utf8');
    
    // Build the AI_IMAGES object string
    const imagesObject = Object.entries(base64Images)
      .map(([key, value]) => `  '${key}': '${value}',`)
      .join('\n');
    
    // Replace the empty AI_IMAGES object with populated one
    const updatedContent = workerContent.replace(
      /const AI_IMAGES = {[\s\S]*?};/,
      `const AI_IMAGES = {\n${imagesObject}\n};`
    );
    
    // Write updated worker script
    fs.writeFileSync(workerPath, updatedContent);
    console.log(`✅ Updated ${workerPath} with ${Object.keys(base64Images).length} images`);
    
  } catch (error) {
    console.error('❌ Error updating worker script:', error.message);
  }
}

function main() {
  console.log('🚀 Starting AI image upload process...\n');
  
  // Convert images to base64
  const base64Images = convertImagesToBase64();
  
  if (Object.keys(base64Images).length === 0) {
    console.log('\n❌ No images were processed. Please check file paths.');
    return;
  }
  
  // Update worker script
  updateWorkerScript(base64Images);
  
  console.log('\n🎉 AI image processing complete!');
  console.log('\nNext steps:');
  console.log('1. Run: wrangler deploy');
  console.log('2. Test your endpoints at: https://missionary-profiles-api.jbr01061981.workers.dev/ai-headshots/');
  console.log('\nAvailable endpoints:');
  Object.keys(base64Images).forEach(filename => {
    console.log(`   - https://missionary-profiles-api.jbr01061981.workers.dev/ai-headshots/${filename}`);
  });
}

main();