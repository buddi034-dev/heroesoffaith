// Node.js script to create optimized image variants and upload to R2
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Check if ImageMagick is available
function checkImageMagick() {
  try {
    execSync('magick -version', { stdio: 'ignore' });
    return true;
  } catch {
    console.log('❌ ImageMagick not found. Please install ImageMagick first.');
    console.log('Download from: https://imagemagick.org/script/download.php#windows');
    return false;
  }
}

// Image variants to generate
const IMAGE_VARIANTS = [
  { suffix: '-thumb', width: 200, height: 250, quality: 85 },
  { suffix: '-card', width: 400, height: 500, quality: 90 },
];

// Image file mappings
const IMAGE_FILES = {
  'alexander-duff-ai.jpg': 'assets/images/Alexander duff new.jpg',
  'amy-carmichael-ai.jpg': 'assets/images/Amy Carmicheal new.jpg',
  'ida-scudder-ai.jpg': 'assets/images/ida scudder new.jpg',
  'james-hudson-taylor-ai.jpg': 'assets/images/james hudson taylor new.jpg',
  'pandita-ramabai-ai.jpg': 'assets/images/pandita ramabai new.jpg',
  'william-carey-ai.jpg': 'assets/images/william carey new.jpg',
};

async function generateOptimizedImages() {
  if (!checkImageMagick()) return;
  
  console.log('🔄 Generating optimized image variants...\n');
  
  for (const [outputName, inputPath] of Object.entries(IMAGE_FILES)) {
    if (!fs.existsSync(inputPath)) {
      console.log(`⚠️  Warning: ${inputPath} not found, skipping ${outputName}`);
      continue;
    }
    
    console.log(`📸 Processing: ${outputName}`);
    
    // Generate variants
    for (const variant of IMAGE_VARIANTS) {
      const outputPath = `temp/${outputName.replace('-ai.jpg', `${variant.suffix}.jpg`)}`;
      
      // Ensure temp directory exists
      if (!fs.existsSync('temp')) {
        fs.mkdirSync('temp');
      }
      
      try {
        // Use ImageMagick to resize and optimize
        const command = `magick "${inputPath}" -resize ${variant.width}x${variant.height}^ -gravity center -extent ${variant.width}x${variant.height} -quality ${variant.quality} "${outputPath}"`;
        execSync(command);
        
        const stats = fs.statSync(outputPath);
        const sizeKB = Math.round(stats.size / 1024);
        console.log(`  ✅ ${variant.suffix}: ${variant.width}x${variant.height} (${sizeKB} KB)`);
        
        // Upload to R2
        const r2ObjectName = outputName.replace('-ai.jpg', `${variant.suffix}.jpg`);
        const uploadCommand = `wrangler r2 object put ai-missionary-headshots/${r2ObjectName} --file="${outputPath}" --remote`;
        execSync(uploadCommand);
        console.log(`  📤 Uploaded to R2: ${r2ObjectName}`);
        
      } catch (error) {
        console.log(`  ❌ Error creating ${variant.suffix}: ${error.message}`);
      }
    }
    console.log();
  }
  
  // Cleanup temp directory
  if (fs.existsSync('temp')) {
    fs.rmSync('temp', { recursive: true });
  }
  
  console.log('🎉 Image optimization complete!');
  console.log('\n📋 Generated variants:');
  console.log('• Thumbnail: 200x250 (for small displays)');
  console.log('• Card: 400x500 (for carousel cards)'); 
  console.log('• Full: Original size (for profile pages)');
}

generateOptimizedImages().catch(console.error);