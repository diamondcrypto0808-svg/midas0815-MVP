module Matching
  class SimilarityCalculator
    def initialize(profile1, profile2)
      @profile1 = profile1
      @profile2 = profile2
    end

    def calculate
      return 1.0 if same_profile?
      return 0.0 if either_profile_nil?

      interests_similarity = calculate_interests_similarity
      skills_similarity = calculate_skills_similarity

      # Weighted average
      (interests_similarity * 0.6 + skills_similarity * 0.4).round(4)
    end

    private

    def same_profile?
      @profile1.id == @profile2.id
    end

    def either_profile_nil?
      @profile1.nil? || @profile2.nil?
    end

    def calculate_interests_similarity
      interests1 = @profile1.interests_list
      interests2 = @profile2.interests_list

      return 0.0 if interests1.empty? && interests2.empty?
      return 0.0 if interests1.empty? || interests2.empty?

      jaccard_similarity(interests1, interests2)
    end

    def calculate_skills_similarity
      skills1 = @profile1.skills_list
      skills2 = @profile2.skills_list

      return 0.0 if skills1.empty? && skills2.empty?
      return 0.0 if skills1.empty? || skills2.empty?

      jaccard_similarity(skills1, skills2)
    end

    def jaccard_similarity(set1, set2)
      set1 = Set.new(set1.map(&:downcase))
      set2 = Set.new(set2.map(&:downcase))

      intersection = (set1 & set2).size
      union = (set1 | set2).size

      return 0.0 if union.zero?

      intersection.to_f / union
    end
  end
end
